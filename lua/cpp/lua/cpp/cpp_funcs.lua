---@meta

M = {}

local ms = require("vim.lsp.protocol").Methods
local sk = require("vim.lsp.protocol").SymbolKind
local lsp = require("cpp.lsp")

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
      -- print("clangd not attached")
      return
   end
   clangd:request("textDocument/switchSourceHeader", {
      uri = vim.uri_from_bufnr(bufnr),
   }, switchHeaderSourceHandler, bufnr)
end

--- Tries to switch between h/cpp buffers
function M.switchHeaderSourceForCurrentBufferSync()
   local bufnr = vim.api.nvim_get_current_buf()
   local clangd = M.getClangd()
   if clangd == nil then
      print("clangd not attached")
      return
   end
   local resp = clangd:request_sync("textDocument/switchSourceHeader", {
      uri = vim.uri_from_bufnr(bufnr),
   }, 30, bufnr)
   if resp ~= nil and resp.result ~= nil then
      local buf = vim.uri_to_bufnr(resp.result) or vim.api.nvim_get_current_buf()
      vim.api.nvim_set_current_buf(buf)
      return true
   end
   return false
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

--- @class WindowSize
--- @field row integer
--- @field col integer
--- @field width integer
--- @field height integer

--- @class WindowCreationInfo : WindowSize
--- @field win integer
--- @field buf integer

--- @param sz WindowSize
--- @param _config table
--- @return WindowCreationInfo
local function create_window(sz, _config)
   local config = _config
      or {
         relative = "editor",
         border = "rounded",
         style = "minimal",
         footer = "cpp pointer",
      }

   config = vim.tbl_extend("force", config, {
      col = sz.col,
      width = sz.width,
      row = sz.row,
      height = sz.height,
   })

   local buf = create_blank_buffer()
   local win = vim.api.nvim_open_win(buf, false, config)
   disable_win_decorations(win)

   return vim.tbl_extend("force", sz, {
      win = win,
      buf = buf,
   })
end

function calc_window_sizes()
   local w = math.ceil(vim.o.columns * 0.7)
   local h = math.ceil(vim.o.lines * 0.7) - 2
   local row = math.ceil((vim.o.lines - h) / 2)
   local col = math.ceil((vim.o.columns - w) / 2)

   local intr_w = 3

   return {
      intr_win_sz = { --- @type WindowSize
         row = row,
         col = col,
         width = intr_w,
         height = h,
      },
      view_win_sz = { --- @type WindowSize
         row = row,
         col = col + intr_w + 2,
         width = w - intr_w - 2,
         height = h,
      },
   }
end

---@class OverviewWindow
---@field winnr integer
---@field width integer
---@field height integer
---@field row integer
---@field col integer

local function create_overview_windows()
   local shared_config = {
      relative = "editor",
      border = "rounded",
      style = "minimal",
      footer = "cpp pointer",
   }

   local szs = calc_window_sizes()
   local intr_win_info = create_window(szs.intr_win_sz, shared_config)
   local view_win_info = create_window(szs.view_win_sz, shared_config)
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

         local szs = calc_window_sizes()
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

local function is_function_inline_definition(buf, sym)
   local uri = vim.uri_from_bufnr(buf)
   local result = vim.lsp.buf_request_sync(buf, ms.textDocument_definition, {
      textDocument = { uri = uri },
      position = sym.selectionRange["start"],
   })

   -- print(vim.inspect(sym), vim.inspect(result))

   -- print(vim.inspect(result[1].result[1].uri), vim.inspect(uri))

   -- if #result ~= 1 or result[1].error then
   --    return true
   -- end
   local captured = result[1].result[1].uri or nil

   return (captured ~= nil) and (captured == uri)
end

function M.create_scope_window()
   local source_buf = vim.api.nvim_get_current_buf()
   local cursor = vim.api.nvim_win_get_cursor(0)
   local win_infos = create_overview_windows()

   --- @param parent Symbol
   --- @param symbol Symbol
   local function fill_view_buf(parent, symbol)
      local msg = {}
      for _, sym in ipairs(parent.children) do
         if sym.detail == symbol.detail then
            goto continue
         end

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

         if is_function_inline_definition(source_buf, sym) then
            goto continue
         end

         local item = vim.api.nvim_buf_get_text(
            source_buf,
            sym.range["start"].line,
            sym.range["start"].character,
            sym.range["end"].line,
            sym.range["end"].character,
            {}
         )

         local total = ""
         for _, part in ipairs(item) do
            local no_space = part:match("^%s*(.*)$") or part
            total = total .. " " .. no_space
         end

         -- skipping auto defined items
         if total:match("%s=%sdefault") or total:match("%s=%sdelete") then
            goto continue
         end

         table.insert(msg, total .. ";")
         ::continue::
      end
      -- print(vim.inspect(msg))
      vim.api.nvim_buf_set_lines(win_infos.view_win_info.buf, 0, 0, false, msg)
   end

   lsp.apply_to_scope_items(source_buf, cursor[1] - 1, cursor[2], fill_view_buf)
end

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
      local scope = lsp.find_parent_symbol_under_cursor({ children = opts })
      if scope == nil then
         print("Cant find parent of symbol")
         return
      end
      open_neighbors_window(scope.parent, scope.symbol)
   end)
end

return M
