return {
   {
      "shortcuts/no-neck-pain.nvim",
      version = "*",
   },
   {
      "kiyoon/jupynium.nvim",
      build = "sudo pacman -S python-jupynium", -- FIXME: Not working on ARCH
      config = function()
         require("jupynium").setup({})
         vim.keymap.set("n", "<leader>jr", function()
            vim.cmd("JupyniumStartAndAttachToServer")
         end, { desc = "[j]upynium [r]tart" })

         vim.keymap.set("n", "<leader>jsy", function()
            vim.cmd("JupyniumStartSync")
         end, { desc = "[j]upynium [s][y]nc" })
      end,
   },
   {
      "uga-rosa/ccc.nvim",
      config = function()
         vim.opt.termguicolors = true
         local ccc = require("ccc")
         ccc.setup({
            highlighter = {
               auto_enable = true,
               lsp = true,
            },
         })
      end,
   },
   {
      "stevearc/oil.nvim",
      ---@module 'oil'
      ---@type oil.SetupOpts
      opts = {},
      -- Optional dependencies
      dependencies = { { "echasnovski/mini.icons", opts = {} } },
      -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if prefer nvim-web-devicons
      config = function()
         vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
         require("oil").setup()
      end,
   },
   {
      "dstein64/vim-startuptime",
   },
   {
      "danymat/neogen",
      config = true,
      -- Uncomment next line if you want to follow only stable versions
      -- version = "*"
   },
   { "xiyaowong/transparent.nvim" },
   { "tpope/vim-sleuth" },

   {
      "lewis6991/gitsigns.nvim",
      opts = {
         signs = {
            add = { text = "+" },
            change = { text = "~" },
            delete = { text = "_" },
            topdelete = { text = "‾" },
            changedelete = { text = "~" },
         },
      },
   },

   {
      "numToStr/Comment.nvim",
      opts = {
         toggler = {
            line = "gcc",
            block = "gbc",
         },
      },
   },
   {
      "folke/which-key.nvim",
      event = "VimEnter",
      config = function()
         require("which-key").setup()
         local keymaps_module = require("keymaps")
         require("which-key").add(keymaps_module.init_whichkey_keymaps())
      end,
   },

   -- Highlight todo, notes, etc in comments
   {
      "folke/todo-comments.nvim",
      event = "VimEnter",
      dependencies = { "nvim-lua/plenary.nvim" },
      opts = { signs = false },
   },
}
