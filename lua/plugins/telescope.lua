local function init_telescope_keymaps(builtin)
   vim.keymap.set("n", "<leader>sh", builtin.help_tags, {
      desc = "[S]earch [H]elp",
   })

   vim.keymap.set("n", "<leader>sk", builtin.keymaps, {
      desc = "[S]earch [K]eymaps",
   })

   vim.keymap.set("n", "<leader>sf", builtin.find_files, {
      desc = "[S]earch [F]iles",
   })

   vim.keymap.set("n", "<leader>ss", builtin.builtin, {
      desc = "[S]earch [S]elect Telescope",
   })

   vim.keymap.set("n", "<leader>sw", builtin.grep_string, {
      desc = "[S]earch current [W]ord",
   })

   vim.keymap.set("n", "<leader>sg", builtin.live_grep, {
      desc = "[S]earch by [G]rep",
   })

   vim.keymap.set("n", "<leader>sd", builtin.diagnostics, {
      desc = "[S]earch [D]iagnostics",
   })

   vim.keymap.set("n", "<leader>sr", builtin.resume, {
      desc = "[S]earch [R]esume",
   })

   vim.keymap.set("n", "<leader>s.", builtin.oldfiles, {
      desc = '[S]earch Recent Files ("." for repeat)',
   })

   vim.keymap.set("n", "<leader><leader>", builtin.buffers, {
      desc = "[ ] Find existing buffers",
   })

   vim.keymap.set("n", "<leader>s/", function()
      builtin.live_grep({
         grep_open_files = true,
         prompt_title = "Live Grep in Open Files",
      })
   end, { desc = "[S]earch [/] in Open Files" })

   -- Shortcut for searching your Neovim configuration files
   vim.keymap.set("n", "<leader>sn", function()
      builtin.find_files({ cwd = vim.fn.stdpath("config") })
   end, { desc = "[S]earch [N]eovim files" })

   vim.keymap.set("n", "<leader>sq", function()
      builtin.buffers({
         attach_mappings = function(prompt_bufnr, map)
            local actions = require("telescope.actions")
            -- Mapping to close the selected buffer
            map("i", "<C-x>", function()
               local selection = require("telescope.actions.state").get_selected_entry()
               if selection then
                  vim.cmd("bdelete " .. selection.value)
                  actions.close(prompt_bufnr)
               end
            end)
            map("n", "<C-x>", function()
               local selection = require("telescope.actions.state").get_selected_entry()
               if selection then
                  vim.cmd("bdelete " .. selection.value)
                  actions.close(prompt_bufnr)
               end
            end)
            return true
         end,
      })
   end, { desc = "[S]earch and [Q]uit (close) selected buffer" })
end

return {
   "nvim-telescope/telescope.nvim",
   event = "VimEnter",
   -- branch = "0.1.x",
   dependencies = {
      "nvim-lua/plenary.nvim",
      {
         "nvim-telescope/telescope-fzf-native.nvim",
         build = "make",
         cond = function()
            return vim.fn.executable("make") == 1
         end,
      },
      { "nvim-telescope/telescope-ui-select.nvim" },
      { "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
   },
   config = function()
      require("telescope").setup({
         extensions = {
            ["ui-select"] = {
               require("telescope.themes").get_dropdown(),
            },
         },
         defaults = {
            preview = {
               treesitter = false,
            },
            file_ignore_patterns = {
               ".git/.*",
               ".github/.*",
               ".*external/.*",
            },
         },
      })

      -- Enable Telescope extensions if they are installed
      pcall(require("telescope").load_extension, "fzf")
      pcall(require("telescope").load_extension, "ui-select")
      -- pcall(require("telescope").load_extension, "themes")

      init_telescope_keymaps(require("telescope.builtin"))
   end,
}
