return {
   {
      "shellRaining/hlchunk.nvim",
      event = { "BufReadPre", "BufNewFile" },
      config = function()
         require("hlchunk").setup({
            chunk = { enable = false },
            indent = {
               enable = true,
            },
         })
      end,
   },

   -- {
   --    "chaoren/vim-wordmotion",
   -- },
   -- {
   --    "boltlessengineer/sense.nvim",
   -- },
   -- {
   --    "kiyoon/jupynium.nvim",
   --    build = "sudo pacman -S python-jupynium", -- FIXME: Not working on ARCH
   --    config = function()
   --       require("jupynium").setup({})
   --       vim.keymap.set("n", "<leader>jr", function()
   --          vim.cmd("JupyniumStartAndAttachToServer")
   --       end, { desc = "[j]upynium [r]tart" })
   --
   --       vim.keymap.set("n", "<leader>jsy", function()
   --          vim.cmd("JupyniumStartSync")
   --       end, { desc = "[j]upynium [s][y]nc" })
   --    end,
   -- },
   -- {
   --    "uga-rosa/ccc.nvim",
   --    config = function()
   --       vim.opt.termguicolors = true
   --       local ccc = require("ccc")
   --       ccc.setup({
   --          highlighter = {
   --             auto_enable = true,
   --             lsp = true,
   --          },
   --       })
   --    end,
   -- },
   -- {
   --    "stevearc/oil.nvim",
   --    ---@module 'oil'
   --    ---@type oil.SetupOpts
   --    opts = {},
   --    -- Optional dependencies
   --    dependencies = { { "echasnovski/mini.icons", opts = {} } },
   --    -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if prefer nvim-web-devicons
   --    config = function()
   --       vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
   --       require("oil").setup()
   --    end,
   -- },
   {
      "dstein64/vim-startuptime",
   },
   {
      "danymat/neogen",
      config = function()
         require("neogen").setup({
            enabled = true,
            input_after_comment = true,
            languages = {
               cpp = {
                  template = {
                     annotation_convention = "doxygen",
                     -- override templates directly
                     templates = {
                        func = {
                           { nil, "//! ${1:Brief description}" },
                           { nil, "//!" },
                           { nil, "//! @param ${2:param} ${3:description}" },
                           { nil, "//! @return ${4:description}" },
                        },
                     },
                  },
               },
            },
         })
      end,
      dependencies = {
         "nvim-treesitter/nvim-treesitter",
      },
   },
   { "xiyaowong/transparent.nvim" },
   { "tpope/vim-sleuth" },

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
         require("which-key").setup({
            win = {
               no_overlap = true,
               padding = { 0, 0 },
               title = true,
               title_pos = "center",
               zindex = 1000,
               border = "rounded", -- <-- Add this line
               bo = {},
               wo = {
                  -- winblend = 10,
               },
            },
         })
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
   {
      "kawre/leetcode.nvim",
      -- build = ":TSUpdate html", -- if you have `nvim-treesitter` installed
      dependencies = {
         -- include a picker of your choice, see picker section for more details
         "nvim-lua/plenary.nvim",
         "MunifTanjim/nui.nvim",
      },
      opts = {
         -- configuration goes here
      },
   },
}
