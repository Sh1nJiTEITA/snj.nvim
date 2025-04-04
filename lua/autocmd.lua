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

return
