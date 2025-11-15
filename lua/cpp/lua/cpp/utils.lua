--- @module 'cpp.lsp'

--- @class CppLsp
local M = {}

--- Creates blank buffer for using in for window inside ui to display some kind
--- of text. Buffer will be deleted if becomes hidden
--- @return integer bufnr
function M.create_blank_buf()
   local bufnr = vim.api.nvim_create_buf(false, true)
   if bufnr == 0 then
      vim.notify("Cant create blank buffer", "error")
   end

   vim.bo[bufnr].bufhidden = "delete"
   vim.bo[bufnr].buftype = "nofile"
   vim.bo[bufnr].swapfile = false
   vim.bo[bufnr].buflisted = false

   return bufnr
end

--- Disables the main window decorations like numbers, cursorline etc ...
--- @param winnr integer Window vim ID
function M.disable_win_decorations(winnr)
   vim.wo[winnr].number = false
   vim.wo[winnr].relativenumber = false
   vim.wo[winnr].colorcolumn = ""
   vim.wo[winnr].cursorline = false
   vim.wo[winnr].signcolumn = "no"
   vim.wo[winnr].linebreak = false
end

--- @return WindowSize
function M.calc_centered_win_sz()
   local w = math.ceil(vim.o.columns * 0.7)
   local h = math.ceil(vim.o.lines * 0.7) - 2
   return {
      width = w,
      height = h,
      row = math.ceil((vim.o.lines - h) / 2),
      col = math.ceil((vim.o.columns - w) / 2),
   }
end

--- @param sz WindowSize
--- @param config? vim.api.keyset.win_config
--- @return WindowCreationInfo
function M.create_window(sz, config)
   local _config = vim.tbl_extend("force", config or {
      relative = "editor",
      border = "rounded",
      style = "minimal",
   }, {
      col = sz.col,
      width = sz.width,
      row = sz.row,
      height = sz.height,
   })

   local buf = M.create_blank_buffer()
   local win = vim.api.nvim_open_win(buf, false, _config)
   M.disable_win_decorations(win)

   return vim.tbl_extend("force", sz, {
      win = win,
      buf = buf,
   })
end

return M
