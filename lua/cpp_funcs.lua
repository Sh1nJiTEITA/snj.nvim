---@meta

M = {}

local ms = require("vim.lsp.protocol").Methods
local sk = require("vim.lsp.protocol").SymbolKind

--- Finds clangd client
---@return vim.lsp.Client | nil clangd client
function M.getClangd()
   local bufnr = vim.api.nvim_get_current_buf()
   local clients = vim.lsp.get_clients({ bufnr = bufnr })
   if #clients ~= 1 then
      return nil
   else
      return clients[1]
   end
end

---@param err string
---@param uri string
local function switchHeaderSourceHandler(err, uri)
   local file_name = vim.uri_to_fname(uri)
   vim.api.nvim_cmd({
      cmd = "edit",
      args = { file_name },
   }, {})
end

--- Tries to switch between h/cpp buffers
function M.switchHeaderSourceForCurrentBuffer()
   local bufnr = vim.api.nvim_get_current_buf()
   local clangd = M.getClangd()
   if clangd == nil then
      print("clangd not attached")
      return
   end
   clangd:request("textDocument/switchSourceHeader", {
      uri = vim.uri_from_bufnr(bufnr),
   }, switchHeaderSourceHandler, bufnr)
end

--- Test func
local function getReferenceListUnderCursor()
   local list = nil
   local on_list = function(options)
      list = options
   end
   vim.lsp.buf.references(nil, { loclist = false, on_list = on_list })
   return list
end

---@param how "dec" | "def" | "impl" | "ref"
function M.run(how)
   local f = function(opts)
      print(vim.inspect(opts))
   end

   if how == "dec" then
      vim.lsp.buf.declaration({ on_list = f })
   elseif how == "def" then
      vim.lsp.buf.definition({ on_list = f })
   elseif how == "impl" then
      vim.lsp.buf.implementation({ on_list = f })
   elseif how == "ref" then
      vim.lsp.buf.references(nil, { on_list = f })
   end
end

function M.goto_definition_or_create_under_cursor()
   vim.lsp.buf.definition({
      on_list = function(opts)
         -- For single function impl
         local filename = opts.items[1].filename
         local s_begin_line = opts.items[1].lnum
         local s_end_line = opts.items[1].end_lnum
         -- print(vim.inspect(opts.items[1]))

         -- If this is true than functin might have
         -- an cpp implementation
         if filename:match(".*cpp$") or filename:match(".*hpp$") then
            print("Impl in cpp/hpp file")
         elseif filename:match(".*h$") then
            print("No impl")
         end

         ---@param syms vim.lsp.LocationOpts.OnList
         local on_list = function(syms)
            local nearest = nil
            local min_distance = math.huge
            -- print(vim.inspect(syms.items))
            for _, s in ipairs(syms.items) do
               local begin_line = s.lnum
               local end_line = s.end_lnum

               if begin_line == s_begin_line or end_line == s_end_line then
                  goto continue
               end

               -- If it symbol upper then input symbol
               if s_begin_line < begin_line and s_begin_line < end_line then
                  local distance = math.abs(s_begin_line - end_line)
                  if distance < min_distance then
                     min_distance = distance
                     nearest = s
                     nearest.distance = distance
                  end
               -- If it symbol below the input symbol
               else
                  local distance = math.abs(s_end_line - begin_line)
                  if distance < min_distance then
                     min_distance = distance
                     nearest = s
                     nearest.distance = distance
                  end
               end
               -- local begin_distance = math.abs()
               -- local start_line = s.range.start.line
               ::continue::
            end
            print(vim.inspect({ input = opts.items[1], nearest = nearest }))
         end

         vim.lsp.buf.document_symbol({
            on_list = on_list,
         })
      end,
   })
end

function M.resolveTest(name)
   -- local clangd = M.getClangd()
   -- print(vim.inspect(clangd.capabilities))

   vim.lsp.buf_request(0, ms.textDocument_documentSymbol, {
      textDocument = { uri = vim.uri_from_bufnr(0) },
   }, function(err, opts)
      print(vim.inspect(opts))
   end)
end

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

---@param sym Symbol
local function is_under_cursor(sym)
   local cursor = vim.api.nvim_win_get_cursor(0)
   local cursor_row = cursor[1] - 1
   local cursor_col = cursor[2]

   local s = sym.range.start
   local e = sym.range["end"]

   local inside_line = (cursor_row >= s.line and cursor_row <= e.line)
   local inside_col = true

   if cursor_row == s.line then
      inside_col = cursor_col >= s.character
   end
   if cursor_row == e.line then
      inside_col = cursor_col <= e.character
   end

   return inside_line and inside_col
end

---@param parent Symbol
---@return table|nil
local function find_parent_symbol(parent)
   for _, sym in ipairs(parent.children) do
      if is_under_cursor(sym) then
         if sym.children then
            local child_found = find_parent_symbol(sym)
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
---@param symbol Symbol
---@return integer | nil
local function find_symbol_index(parent, symbol)
   for i, sym in ipairs(parent.children) do
      if is_under_cursor(sym) then
         return i
      end
   end
   return nil
end

---@param parent Symbol
---@param symbol Symbol
---@return table
local function find_neighbors(parent, symbol)
   local sym_idx = find_symbol_index(parent, symbol)
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

local function create_blank_buffer()
   local bufnr = vim.api.nvim_create_buf(false, true)
   if bufnr == 0 then
      print("cant create buffer")
   end

   vim.bo[bufnr].bufhidden = "delete"
   vim.bo[bufnr].buftype = "nofile"
   vim.bo[bufnr].swapfile = false
   vim.bo[bufnr].buflisted = false

   return bufnr
end

local function disable_win_decorations(winnr)
   vim.wo[winnr].number = false
   vim.wo[winnr].relativenumber = false
   vim.wo[winnr].colorcolumn = ""
   vim.wo[winnr].cursorline = false
   vim.wo[winnr].signcolumn = "no"
   vim.wo[winnr].linebreak = false
end

---@return integer
local function create_overview_window()
   local w = math.ceil(vim.o.columns * 0.7)
   local h = math.ceil(vim.o.lines * 0.7)
   local config = {
      relative = "editor",
      width = w,
      height = h,
      row = math.ceil((vim.o.lines - h) / 2),
      col = math.ceil((vim.o.columns - w) / 2),
      border = "rounded",
      style = "minimal",
      footer = "cpp pointer",
   }
   local bufnr = create_blank_buffer()
   local winnr = vim.api.nvim_open_win(bufnr, false, config)
   disable_win_decorations(winnr)
   return winnr
end

-- ---@return table
-- local win_is_opened = false
-- local function create_neighbors_window()
--    if win_is_opened then
--       return
--    end
--    local source_bufnr = vim.api.nvim_get_current_buf()
--    local overview_winnr = create_overview_window()
--
--    local code_bufnr = create_blank_buffer()
--    vim.api.nvim_buf_set_option(code_bufnr, "filetype", "cpp")
--    local interaction_bufnr = create_blank_buffer()
--
--    local interaction_win_config = {
--       win = overview_winnr,
--       row = 1,
--       col = 1,
--       width = 2,
--       height = vim.api.nvim_win_get_height(overview_winnr),
--       relative = "win",
--    }
--    local code_win_config = {
--       win = overview_winnr,
--       row = 1,
--       col = 3,
--       width = vim.api.nvim_win_get_width(overview_winnr) - 2,
--       height = vim.api.nvim_win_get_height(overview_winnr),
--       relative = "win",
--    }
--
--    local code_winnr = vim.api.nvim_open_win(code_bufnr, true, code_win_config)
--    local interaction_winnr = vim.api.nvim_open_win(interaction_bufnr, true, interaction_win_config)
--
--    disable_win_decorations(code_winnr)
--    disable_win_decorations(interaction_winnr)
--
--    local cleanup = function()
--       for _, winnr in ipairs({ overview_winnr, code_winnr, interaction_winnr }) do
--          if vim.api.nvim_win_is_valid(winnr) then
--             vim.api.nvim_win_close(winnr, true)
--          end
--       end
--
--       for _, bufnr in ipairs({ code_bufnr, interaction_bufnr }) do
--          if vim.api.nvim_buf_is_valid(bufnr) then
--             vim.api.nvim_buf_delete(bufnr, { force = true })
--          end
--       end
--
--       win_is_opened = false
--    end
--
--    win_is_opened = true
--    vim.api.nvim_buf_set_keymap(interaction_bufnr, "n", "q", "", {
--       noremap = true,
--       silent = true,
--       callback = cleanup,
--    })
--
--    vim.api.nvim_create_autocmd({ "bufleave", "winleave" }, {
--       buffer = interaction_bufnr,
--       once = true,
--       callback = cleanup,
--    })
--
--    return {
--       source_bufnr = source_bufnr,
--       code_winnr = code_winnr,
--       code_bufnr = code_bufnr,
--       interaction_winnr = interaction_winnr,
--       interaction_bufnr = interaction_bufnr,
--    }
-- end

---@return table
local win_is_opened = false
local function create_neighbors_window()
   if win_is_opened then
      return
   end

   -- 1. Calculate the geometry for the entire component first.
   local total_w = math.ceil(vim.o.columns * 0.7)
   local total_h = math.ceil(vim.o.lines * 0.7)
   local start_row = math.ceil((vim.o.lines - total_h) / 2)
   local start_col = math.ceil((vim.o.columns - total_w) / 2)

   -- 2. Create the outer "shell" window. It's not focusable.
   -- This window's only job is to draw the border and footer.
   local border_buf = create_blank_buffer()
   local border_winnr = vim.api.nvim_open_win(border_buf, false, { -- Note: `enter` is false
      relative = "editor",
      width = total_w,
      height = total_h,
      row = start_row,
      col = start_col,
      border = "rounded",
      footer = "cpp pointer",
      style = "minimal",
      focusable = false, -- This is crucial!
   })

   -- 3. Calculate the dimensions of the area *inside* the border.
   local inner_area_w = total_w - 2
   local inner_area_h = total_h - 2
   local inner_start_row = start_row + 1
   local inner_start_col = start_col + 1

   -- Define the split ratio
   local interaction_w = 25
   local code_w = inner_area_w - interaction_w

   -- 4. Create the actual buffers for your content.
   local source_bufnr = vim.api.nvim_get_current_buf()
   local code_bufnr = create_blank_buffer()
   vim.api.nvim_buf_set_option(code_bufnr, "filetype", "cpp")
   local interaction_bufnr = create_blank_buffer()

   -- 5. Create the two inner windows, without borders, positioned inside the shell.
   -- The first window created with `enter = true` will receive focus.
   local interaction_winnr = vim.api.nvim_open_win(interaction_bufnr, true, {
      relative = "editor",
      row = inner_start_row,
      col = inner_start_col,
      width = interaction_w,
      height = inner_area_h,
   })

   local code_winnr = vim.api.nvim_open_win(code_bufnr, false, { -- Note: `enter` is false
      relative = "editor",
      row = inner_start_row,
      col = inner_start_col + interaction_w, -- Positioned right next to the interaction window
      width = code_w,
      height = inner_area_h,
   })

   -- 6. Apply window options and setup cleanup.
   disable_win_decorations(code_winnr)
   disable_win_decorations(interaction_winnr)

   local cleanup = function()
      -- Make sure to clean up ALL windows and buffers that were created.
      local windows_to_close = { border_winnr, code_winnr, interaction_winnr }
      for _, winnr in ipairs(windows_to_close) do
         if vim.api.nvim_win_is_valid(winnr) then
            vim.api.nvim_win_close(winnr, true)
         end
      end

      local buffers_to_delete = { border_buf, code_bufnr, interaction_bufnr }
      for _, bufnr in ipairs(buffers_to_delete) do
         if vim.api.nvim_buf_is_valid(bufnr) then
            vim.api.nvim_buf_delete(bufnr, { force = true })
         end
      end

      win_is_opened = false
   end

   win_is_opened = true
   vim.api.nvim_buf_set_keymap(interaction_bufnr, "n", "q", "", {
      noremap = true,
      silent = true,
      callback = cleanup,
   })

   vim.api.nvim_create_autocmd("WinLeave", {
      buffer = interaction_bufnr,
      once = true,
      callback = cleanup,
   })
   -- Also trigger cleanup if the code buffer is left
   vim.api.nvim_create_autocmd("WinLeave", {
      buffer = code_bufnr,
      once = true,
      callback = cleanup,
   })

   return {
      source_bufnr = source_bufnr,
      code_winnr = code_winnr,
      code_bufnr = code_bufnr,
      interaction_winnr = interaction_winnr,
      interaction_bufnr = interaction_bufnr,
   }
end

local function remove_common_indent(lines)
   -- Step 1: Find minimal indent (ignore empty lines)
   local min_indent = math.huge
   for _, line in ipairs(lines) do
      local current = line:match("^(%s*)%S")
      if current then
         min_indent = math.min(min_indent, #current)
      end
   end
   if min_indent == math.huge then
      min_indent = 0
   end

   -- Step 2: Remove min_indent from each line
   local result = {}
   for _, line in ipairs(lines) do
      table.insert(result, line:sub(min_indent + 1))
   end
   return result
end

function string.starts(String, Start)
   return string.sub(String, 1, string.len(Start)) == Start
end

local SYMBOLKINDS_TO_SKIP = {
   [sk.Field] = "F ",
   [sk.Class] = "CL",
   [sk.Variable] = "V ",
   [sk.Method] = "M ",
   [sk.Constructor] = "C ",
   [sk.Interface] = "I ",
   [sk.Enum] = "E ",
   [sk.Function] = "F ",
}

---@param parent Symbol
---@param current Symbol
local function open_neighbors_window(parent, current)
   local winbufdata = create_neighbors_window()
   local msg = {} ---@type table<string>
   for i, symbol in ipairs(parent.children) do
      -- if SYMBOLKINDS_TO_SKIP[symbol.kind] ~= nil then
      --    goto continue
      -- end

      local item = vim.api.nvim_buf_get_text(
         winbufdata.source_bufnr,
         symbol.range["start"].line,
         symbol.range["start"].character,
         symbol.range["end"].line,
         symbol.range["end"].character,
         {}
      )

      -- Connect multiline definitions
      local total = ""
      for _, part in ipairs(item) do
         local no_space = part:match("^%s*(.*)$") or part
         total = total .. " " .. no_space
      end

      local icon = SYMBOLKINDS_TO_SKIP[symbol.kind] or "0 "

      -- Process tempalate funcs
      if string.starts(symbol.detail, "template") then
         local new_total, _ = total:gsub("%s{.*}", "")
         total = new_total
         icon = "TM"
      end

      table.insert(msg, icon .. " │ " .. total .. ";")
      ::continue::
   end

   vim.api.nvim_buf_set_lines(winbufdata.code_bufnr, 0, 0, false, msg)
   vim.bo[winbufdata.code_bufnr].modifiable = false
   vim.bo[winbufdata.interaction_bufnr].modifiable = false
end

function M.show_all_neighbors_under_cursor()
   vim.lsp.buf_request(0, ms.textDocument_documentSymbol, {
      textDocument = { uri = vim.uri_from_bufnr(0) },
   }, function(err, opts)
      if err ~= nil then
         print(vim.inspect(err))
         return
      end
      local scope = find_parent_symbol({ children = opts })
      if scope == nil then
         print("Cant find parent of symbol")
         return
      end
      open_neighbors_window(scope.parent, scope.symbol)
   end)
end

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
         print(vim.inspect(err))
         return
      end
      -- print(vim.inspect(result))
      vim.lsp.util.show_document({
         uri = result[1].uri,
      }, "utf-8")
      vim.api.nvim_win_set_cursor(0, { result[1].range.start.line, result[1].range.start.character })
   end)
end

---@param apply_to_neighbors function(table<Symbol>)
function M.get_neighbors_under_cursor(apply_to_neighbors)
   vim.lsp.buf_request(0, ms.textDocument_documentSymbol, {
      textDocument = { uri = vim.uri_from_bufnr(0) },
   }, function(err, opts)
      local scope = find_parent_symbol({ children = opts })
      local parent = scope.parent
      local symbol = scope.symbol
      if parent ~= nil and symbol ~= nil then
         local neighbors = find_neighbors(parent, symbol)
         apply_to_neighbors(neighbors)
      end
   end)
end

function M.print_neighbors_under_cursor()
   vim.lsp.buf_request(0, ms.textDocument_documentSymbol, {
      textDocument = { uri = vim.uri_from_bufnr(0) },
   }, function(err, opts)
      local scope = find_parent_symbol({ children = opts })
      local parent = scope.parent
      local symbol = scope.symbol
      if parent ~= nil and symbol ~= nil then
         local neighbors = find_neighbors(parent, symbol)
         local items = {}
         for typename, item in pairs(neighbors) do
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
