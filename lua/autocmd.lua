-- Loads lazy vim ... ---------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
   local lazyrepo = "https://github.com/folke/lazy.nvim.git"
   vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
end ---@diagnostic disable-next-line: undefined-field

vim.opt.rtp:prepend(lazypath)
-- Loads lazy vim ... ---------------------------------------------------------

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

function AddTaskNumbers(base)
   local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
   local counters = {}
   local result = {}

   -- parse the base prefix into numbers (e.g. "1.6" → {1, 6})
   local baseParts = {}
   if base then
      for part in tostring(base):gmatch("%d+") do
         table.insert(baseParts, tonumber(part))
      end
   end

   for _, line in ipairs(lines) do
      local level = select(2, line:gsub("\t", "")) -- count tabs

      -- ensure all deeper levels exist
      for i = 1, level + 1 do
         if counters[i] == nil then
            counters[i] = 0
         end
      end

      counters[level + 1] = counters[level + 1] + 1
      for i = level + 2, #counters do
         counters[i] = nil
      end

      -- join base + current counters up to depth
      local parts = vim.deepcopy(baseParts)
      for i = 1, level + 1 do
         table.insert(parts, counters[i])
      end
      local num = table.concat(parts, ".")

      -- insert number
      local new_line = line:gsub("(- %[ %] )", "%1" .. num .. " ")
      table.insert(result, new_line)
   end

   vim.api.nvim_buf_set_lines(0, 0, -1, false, result)
end

vim.api.nvim_create_user_command("AddTaskNums", function(opts)
   AddTaskNumbers(opts.args ~= "" and opts.args or nil)
end, { nargs = "?" })

vim.api.nvim_create_user_command("Impl", function(opts)
   local bufnr = vim.api.nvim_get_current_buf()
   local start_line = opts.line1
   local end_line = opts.line2

   local lines = vim.api.nvim_buf_get_lines(bufnr, start_line - 1, end_line, false)

   print(vim.inspect(lines))
end, {
   range = true,
   nargs = "*",
})

return
