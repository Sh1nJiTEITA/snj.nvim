-- Loads lazy vim ... ---------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
   local lazyrepo = "https://github.com/folke/lazy.nvim.git"
   vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)
-- Loads lazy vim ... ---------------------------------------------------------

local function ConvertDoxygenToCppStyle(start_line, end_line)
   local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
   local new_lines = {}

   for _, line in ipairs(lines) do
      local trimmed = vim.trim(line)

      if trimmed == "/**" or trimmed == "*/" then
         goto continue
      end

      trimmed = trimmed:gsub("^%s*%*%s?", "")

      table.insert(new_lines, "//! " .. trimmed)

      ::continue::
   end

   vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, new_lines)
end

vim.api.nvim_create_user_command("ConvertComment", function(opts)
   ConvertDoxygenToCppStyle(opts.line1, opts.line2)
end, { nargs = 0, range = true })

vim.keymap.set("n", "<leader>8", function()
   -- require("cpp").main.goto_definition_or_create_under_cursor()
   --
   local c = vim.api.nvim_win_get_cursor(0)
   local buf = vim.api.nvim_get_current_buf()
   require("cpp").lsp.apply_to_scope_items(buf, c[1] - 1, c[2], function(parent, symbol)
      print(vim.inspect(parent))
   end)
end, { desc = "Move focus to the upper window" })

vim.keymap.set("n", "<leader>7", function()
   -- require("cpp").main.show_all_neighbors_under_cursor()
   require("cpp").main.create_scope_window()
end, { desc = "Move focus to the upper window" })

local function iso_timestamp()
   local t = os.time()
   local utc = os.time(os.date("!*t", t))
   local diff = os.difftime(t, utc)

   local sign = diff >= 0 and "+" or "-"
   diff = math.abs(diff)
   local hours = math.floor(diff / 3600)
   local minutes = math.floor((diff % 3600) / 60)

   return os.date("%Y-%m-%dT%H:%M:%S", t) .. string.format("%s%02d:%02d", sign, hours, minutes)
end

vim.api.nvim_create_user_command("Timestamp", function(opts)
   local ts = iso_timestamp()
   vim.api.nvim_put({ ts }, "c", true, true)
end, {
   -- nargs = "?",
})

vim.api.nvim_create_user_command("UI", function(opts)
   local mod = require("cpp")
   local ui = mod.win.ScopeUI:new()
   ui:update_scope()
   ui:update_wins()
end, {})

return
