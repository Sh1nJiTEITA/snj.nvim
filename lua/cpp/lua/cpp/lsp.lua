---@meta
local M = {}

local ms = require("vim.lsp.protocol").Methods
local sk = require("vim.lsp.protocol").SymbolKind

---@class Position
---@field line integer
---@field character integer

---@class Range
---@field start Position
---@field end Position

---@class Symbol
---@field name string?
---@field detail string?
---@field kind integer
---@field range Range
---@field selectionRange Range
---@field children? table<Symbol>

--- @param row integer
--- @param col integer
--- @param sym Symbol
function is_under(row, col, sym)
   local s = sym.range.start
   local e = sym.range["end"]

   local inside_line = (row >= s.line and row <= e.line)
   local inside_col = true

   if row == s.line then
      inside_col = col >= s.character
   end
   if row == e.line then
      inside_col = col <= e.character
   end

   return inside_line and inside_col
end

---@param sym Symbol
function M.is_under_cursor(sym)
   local cursor = vim.api.nvim_win_get_cursor(0)
   local cursor_row = cursor[1] - 1
   local cursor_col = cursor[2]
   return is_under(cursor_row, cursor_col, sym)
end

--- @param row integer
--- @param col integer
--- @param parent Symbol
--- @return { symbol: Symbol, parent: Symbol } | nil
function M.find_parent_symbol(row, col, parent)
   for _, sym in ipairs(parent.children) do
      if is_under(row, col, sym) then
         if sym.children then
            local child_found = M.find_parent_symbol(row, col, sym)
            if child_found then
               return child_found
            end
         end

         return {
            symbol = sym,
            parent = parent,
         }
      end
   end
   return nil
end

---@param parent Symbol
---@return table|nil
function M.find_parent_symbol_under_cursor(parent)
   local cursor = vim.api.nvim_win_get_cursor(0)
   local cursor_row = cursor[1] - 1
   local cursor_col = cursor[2]
   return M.find_parent_symbol(cursor_row, cursor_col, parent)
end

---@param parent Symbol
---@param symbol Symbol
---@return integer | nil
function M.find_symbol_index(parent, symbol)
   for i, sym in ipairs(parent.children) do
      if M.is_under_cursor(sym) then
         return i
      end
   end
   return nil
end

---@param parent Symbol
---@param symbol Symbol
---@return table
function M.find_neighbors(parent, symbol)
   local sym_idx = M.find_symbol_index(parent, symbol)
   local total = #parent.children
   if sym_idx ~= nil then
      if sym_idx == total then
         return {
            left = parent.children[sym_idx - 1],
         }
      elseif sym_idx == 1 then
         return {
            right = parent.children[sym_idx + 1],
         }
      else
         return {
            left = parent.children[sym_idx - 1],
            right = parent.children[sym_idx + 1],
         }
      end
   end

   return {}
end

---@unused
---@param symbol Symbol
function M.find_symbol_impl(symbol)
   vim.lsp.buf_request(vim.api.nvim_get_current_buf(), ms.textDocument_definition, {
      textDocument = {
         uri = vim.uri_from_bufnr(0),
      },
      position = {
         line = symbol.selectionRange.start.line,
         character = symbol.selectionRange.start.character,
      },
   }, function(err, result)
      if err then
         vim.notify(vim.inspect(err), "error")
         return
      end
      -- print(vim.inspect(result))
      vim.lsp.util.show_document({
         uri = result[1].uri,
      }, "utf-8")
      vim.api.nvim_win_set_cursor(0, { result[1].range.start.line, result[1].range.start.character })
   end)
end

---@param apply_to_neighbors function(Symbol[])
function M.get_neighbors_under_cursor(buf, apply_to_neighbors)
   vim.lsp.buf_request(buf, ms.textDocument_documentSymbol, {
      textDocument = { uri = vim.uri_from_bufnr(buf) },
   }, function(err, opts)
      local scope = M.find_parent_symbol_under_cursor({ children = opts })
      local parent = scope.parent
      local symbol = scope.symbol
      if parent ~= nil and symbol ~= nil then
         print(vim.inspect(scope))
         local neighbors = M.find_neighbors(parent, symbol)
         apply_to_neighbors(neighbors)
      end
   end)
end

--- @param bufnr integer Buffer vim ID
--- @return Symbol[]?
function M.get_document_symbols(bufnr)
   local resp = vim.lsp.buf_request_sync(bufnr, ms.textDocument_documentSymbol, {
      textDocument = { uri = vim.uri_from_bufnr(bufnr) },
   }, 1000)

   if resp == nil then
      return nil
   end

   for _, results in pairs(resp) do
      if results.result then
         return results.result
      end
   end

   return nil
end

--- @param symbols Symbol[]
--- @param row? integer
--- @param col? integer
--- @return { scope_symbol: Symbol, current_symbol: Symbol }?
function M.find_scope_symbols(symbols, row, col)
   local cursor = vim.api.nvim_win_get_cursor(0)
   row = row or cursor[1] - 1 -- zero based
   col = col or cursor[2] -- one based
   local found = M.find_parent_symbol(row, col, { children = symbols })
   if found then
      return { scope_symbol = found.parent, current_symbol = found.symbol }
   end
   return nil
end

--- @param buf integer
--- @param row integer
--- @param col integer
--- @param func function(Symbol, Symbol)
function M.apply_to_scope_items(buf, row, col, func)
   vim.lsp.buf_request(buf, ms.textDocument_documentSymbol, {
      textDocument = { uri = vim.uri_from_bufnr(buf) },
   }, function(err, opts)
      local scope = M.find_parent_symbol(row, col, { children = opts })
      local parent = scope.parent
      local symbol = scope.symbol
      if parent ~= nil and symbol ~= nil then
         func(parent, symbol)
      else
         vim.notify("Scope items was not found", "error")
      end
   end)
end

---@unused
function M.print_neighbors_under_cursor()
   vim.lsp.buf_request(0, ms.textDocument_documentSymbol, {
      textDocument = { uri = vim.uri_from_bufnr(0) },
   }, function(err, opts)
      local scope = M.find_parent_symbol_under_cursor({ children = opts })
      local parent = scope.parent
      local symbol = scope.symbol
      if parent ~= nil and symbol ~= nil then
         local neighbors = M.find_neighbors(parent, symbol)
         local items = {}
         for _, item in pairs(neighbors) do
            table.insert(items, {
               bufnr = vim.api.nvim_get_current_buf(),
               lnum = item.range["start"].line + 1,
               end_lnum = item.range["end"].line + 1,
               col = item.range["start"].character,
               end_col = item.range["end"].character,
            })
         end
         local list = {
            title = "Neighbors",
            items = items,
            context = {
               method = ms.textDocument_references,
               bufnr = vim.api.nvim_get_current_buf(),
            },
         }
         print(vim.inspect(neighbors))
         -- vim.fn.setqflist({}, " ", list)
         -- vim.cmd("botright copen")
      end
   end)
end

return M
