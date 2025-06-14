-- Loads lazy vim ... ------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
   local lazyrepo = "https://github.com/folke/lazy.nvim.git"
   vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
end ---@diagnostic disable-next-line: undefined-field

vim.opt.rtp:prepend(lazypath)
-- Loads lazy vim ... ------------------------------------------------------------

local function ToggleTheme()
   local current_theme = vim.o.background

   if current_theme == "dark" then
      require("gruvbox").setup({
         transparent_mode = false,
      })
      vim.o.background = "light"
   end
   if current_theme == "light" then
      require("gruvbox").setup({
         transparent_mode = true,
      })
      vim.o.background = "dark"
   end

   -- vim.o.background = "light"
end

vim.api.nvim_create_user_command("ToggleTheme", function()
   ToggleTheme()
end, { nargs = 0 })

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

return
