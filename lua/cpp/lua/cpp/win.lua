--- @module 'cpp.win'

--- @class CppWin
local M = {}

local utils = require("cpp.utils")
local lsp = require("cpp.lsp")

--- @class ScopeUI
--- @field new fun(): ScopeUI Creates new scope ui
--- @field update_scope fun(self, x, y) Updates inner window data
--- @field update_wins fun(self)
--- @field win_datas {intr_win_info: WindowCreationInfo, view_win_info: WindowCreationInfo } Stores ui windows data
--- @field capture_and_format_item fun(self, sym: Symbol): string
--- @field chosen_symbol_ns integer
--- @field source_buf integer vim initial buffer ID from which new() was called
--- @field source_win integer
--- @field scope_sym Symbol Scope symbol that handles scope_syms
--- @field hovered_item_idx integer
--- @field items Symbol[]
local ScopeUI = {}
ScopeUI.__index = ScopeUI

--- @return { intr_win_sz: WindowSize, view_win_sz: WindowSize }
local function calc_scope_ui_win_szs()
   local calculated = utils.calc_centered_win_sz()
   local intr_w = 3

   return {
      intr_win_sz = { --- @type WindowSize
         row = calculated.row,
         col = calculated.col,
         width = intr_w,
         height = calculated.height,
      },
      view_win_sz = { --- @type WindowSize
         row = calculated.row,
         col = calculated.col + intr_w + 2,
         width = calculated.width - intr_w - 2,
         height = calculated.height,
      },
   }
end

local function create_ui_windows()
   local shared_config = {
      relative = "editor",
      border = "rounded",
      style = "minimal",
   }

   local szs = calc_scope_ui_win_szs()

   local intr_win_info = utils.create_window(szs.intr_win_sz, shared_config)
   local view_win_info = utils.create_window(szs.view_win_sz, shared_config)
   vim.api.nvim_buf_set_option(view_win_info.buf, "filetype", "cpp")

   local cleanup = function()
      --- @param window_info WindowCreationInfo
      local cleanup_win = function(window_info)
         if vim.api.nvim_win_is_valid(window_info.win) then
            vim.api.nvim_win_close(window_info.win, true)
         end

         if vim.api.nvim_buf_is_valid(window_info.buf) then
            vim.api.nvim_buf_delete(window_info.buf, { force = true })
         end
      end

      cleanup_win(intr_win_info)
      cleanup_win(view_win_info)
   end

   vim.api.nvim_set_current_win(intr_win_info.win)
   vim.api.nvim_create_autocmd({ "BufHidden", "BufLeave" }, {
      buffer = intr_win_info.buf,
      callback = cleanup,
   })

   vim.api.nvim_create_autocmd({ "VimResized" }, {
      callback = function()
         --- @param win_info WindowCreationInfo
         --- @param win_sz WindowSize
         local update_win_sz = function(win_info, win_sz)
            win_info = vim.tbl_extend("force", win_info, win_sz)
            local config = vim.tbl_extend("force", win_sz, shared_config)
            vim.api.nvim_win_set_config(win_info.win, config)
         end

         szs = calc_scope_ui_win_szs()
         update_win_sz(intr_win_info, szs.intr_win_sz)
         update_win_sz(view_win_info, szs.view_win_sz)
      end,
   })

   vim.api.nvim_buf_set_keymap(intr_win_info.buf, "n", "q", "", { callback = cleanup })

   return {
      intr_win_info = intr_win_info, --- @type WindowCreationInfo
      view_win_info = view_win_info, --- @type WindowCreationInfo
   }
end

function ScopeUI:new()
   local self = setmetatable({}, ScopeUI)
   self.source_buf = vim.api.nvim_get_current_buf()
   self.source_win = vim.api.nvim_get_current_win()
   self.chosen_symbol_ns = vim.api.nvim_create_namespace("CppChosenSymbolNs")
   self.win_datas = create_ui_windows()
   return self
end

--- @param items Symbol[]
--- @return Symbol[]
local function filter_scope_items(items)
   local filtered = {}
   for _, sym in ipairs(items) do
      -- skipping tempalate items
      if string.starts(sym.detail, "template") then
         goto continue
      end

      -- skipping if field
      if sym.kind == 8 then
         goto continue
      end

      -- skipping if alias
      if sym.kind == 5 then
         goto continue
      end

      -- skipping if global var
      if sym.kind == 13 then
         goto continue
      end

      table.insert(filtered, sym)
      ::continue::
   end

   return filtered
end

--- @param x? integer X-pos to resolve scope from
--- @param y? integer Y-pos to resolve scope from
function ScopeUI:update_scope(x, y)
   local symbols = lsp.get_document_symbols(self.source_buf)
   if symbols == nil then
      vim.notify("Cant get document symbols", "error")
      return
   end
   local cursor = vim.api.nvim_win_get_cursor(self.source_win)
   x = x or cursor[1] - 1
   y = y or cursor[2]
   local found = lsp.find_scope_symbols(symbols, x, y)
   if found == nil then
      vim.notify("Cant found parent and current", "error")
      return
   end

   self.current_sym = found.current_symbol
   self.parent_sym = found.scope_symbol
   self.items = {}

   local filtered_syms = filter_scope_items(self.parent_sym.children)
   for _, sym in ipairs(filtered_syms) do
      table.insert(self.items, {
         symbol = sym,
         is_hovered = false,
      })
   end
end

--- @param sym Symbol
--- @return string
function ScopeUI:capture_and_format_item(sym)
   local sym_text = vim.api.nvim_buf_get_text(
      self.source_buf,
      sym.range["start"].line,
      sym.range["start"].character,
      sym.range["end"].line,
      sym.range["end"].character,
      {}
   )

   local total = ""
   for _, part in ipairs(sym_text) do
      local no_space = part:match("^%s*(.*)$") or part
      total = total .. " " .. no_space
   end
   total = total .. ";"

   local view_width = #total
   local width_per_row = self.win_datas.view_win_info.width
   local integral_rows = math.floor(view_width / width_per_row)
   local residual_cols = width_per_row - (view_width % width_per_row)
   if residual_cols < 0 then
      residual_cols = 0
   elseif integral_rows >= 1 then
      residual_cols = residual_cols - 2
   else
      residual_cols = residual_cols - 1
   end

   total = total .. string.rep(" ", residual_cols)
   return total
end

function ScopeUI:update_wins()
   local intr_buf = self.win_datas.intr_win_info.buf
   local view_buf = self.win_datas.view_win_info.buf

   local indices = {}
   local views = {}

   local single_intr_placeholder = string.rep(" ", self.win_datas.intr_win_info.width)
   for i, item in ipairs(self.items) do
      local formatted_item = self:capture_and_format_item(item.symbol)
      local allocated_intr_rows = math.floor(#formatted_item / self.win_datas.view_win_info.width) + 1

      table.insert(indices, string.rep(single_intr_placeholder, allocated_intr_rows))
      table.insert(views, formatted_item)
   end

   vim.api.nvim_buf_set_lines(intr_buf, 0, #indices, false, indices)
   vim.api.nvim_buf_set_lines(view_buf, 0, #views, false, views)

   vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
      buffer = intr_buf,
      callback = function()
         vim.api.nvim_buf_clear_namespace(intr_buf, self.chosen_symbol_ns, 0, -1)
         vim.api.nvim_buf_clear_namespace(view_buf, self.chosen_symbol_ns, 0, -1)
         local cursor = vim.api.nvim_win_get_cursor(0)
         local row = cursor[1] - 1
         vim.api.nvim_buf_add_highlight(intr_buf, self.chosen_symbol_ns, "Visual", row, 0, -1)
         vim.api.nvim_buf_add_highlight(view_buf, self.chosen_symbol_ns, "Visual", row, 0, -1)
         self.hovered_item_idx = row
      end,
   })
end

M.ScopeUI = ScopeUI

return M
