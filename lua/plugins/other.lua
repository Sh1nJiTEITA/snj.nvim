return {
   -- {
   --    "shellRaining/hlchunk.nvim",
   --    event = { "BufReadPre", "BufNewFile" },
   --    config = function()
   --       require("hlchunk").setup({
   --          chunk = { enable = false },
   --          indent = {
   --             enable = true,
   --          },
   --       })
   --    end,
   -- },

   -- {
   --    "chaoren/vim-wordmotion",
   -- },
   -- {
   --    "boltlessengineer/sense.nvim",
   -- },
   {
      "kiyoon/jupynium.nvim",
      -- build = "sudo pacman -S python-jupynium", -- FIXME: Not working on ARCH
      config = function()
         require("jupynium").setup({})
         vim.keymap.set("n", "<leader>jr", function()
            vim.cmd("JupyniumStartAndAttachToServer")
         end, { desc = "[j]upynium s[r]tart" })

         vim.keymap.set("n", "<leader>jsy", function()
            vim.cmd("JupyniumStartSync")
         end, { desc = "[j]upynium [s][y]nc" })

         vim.keymap.set("n", "<leader>jss", function()
            vim.cmd("JupyniumStopSync")
         end, { desc = "[j]upynium [s]top [s]ync" })
      end,
   },
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
   -- {
   --    "dstein64/vim-startuptime",
   -- },
   -- {
   --    "danymat/neogen",
   --    config = function()
   --       require("neogen").setup({
   --          enabled = true,
   --          input_after_comment = true,
   --          languages = {
   --             cpp = {
   --                template = {
   --                   annotation_convention = "doxygen",
   --                   -- override templates directly
   --                   templates = {
   --                      func = {
   --                         { nil, "//! ${1:Brief description}" },
   --                         { nil, "//!" },
   --                         { nil, "//! @param ${2:param} ${3:description}" },
   --                         { nil, "//! @return ${4:description}" },
   --                      },
   --                   },
   --                },
   --             },
   --          },
   --       })
   --    end,
   --    dependencies = {
   --       "nvim-treesitter/nvim-treesitter",
   --    },
   -- },
   -- { "xiyaowong/transparent.nvim" },
   -- { "tpope/vim-sleuth" },

   -- {
   --    "numToStr/Comment.nvim",
   --    opts = {
   --       toggler = {
   --          line = "gcc",
   --          block = "gbc",
   --       },
   --    },
   -- },
   {
      "folke/which-key.nvim",
      event = "VimEnter",
      -- config = function()
      --    require("which-key").setup({
      --       win = {
      --          no_overlap = true,
      --          padding = { 0, 0 },
      --          title = true,
      --          title_pos = "center",
      --          zindex = 1000,
      --          border = "rounded", -- <-- Add this line
      --          bo = {},
      --          wo = {
      --             -- winblend = 10,
      --          },
      --       },
      --    })
      --    local keymaps_module = require("keymaps")
      --    require("which-key").add(keymaps_module.init_whichkey_keymaps())
      -- end,
      opts = {
         delay = 0,
         icons = {
            mappings = vim.g.have_nerd_font,
            keys = vim.g.have_nerd_font and {} or {
               Up = "<Up> ",
               Down = "<Down> ",
               Left = "<Left> ",
               Right = "<Right> ",
               C = "<C-…> ",
               M = "<M-…> ",
               D = "<D-…> ",
               S = "<S-…> ",
               CR = "<CR> ",
               Esc = "<Esc> ",
               ScrollWheelDown = "<ScrollWheelDown> ",
               ScrollWheelUp = "<ScrollWheelUp> ",
               NL = "<NL> ",
               BS = "<BS> ",
               Space = "<Space> ",
               Tab = "<Tab> ",
               F1 = "<F1>",
               F2 = "<F2>",
               F3 = "<F3>",
               F4 = "<F4>",
               F5 = "<F5>",
               F6 = "<F6>",
               F7 = "<F7>",
               F8 = "<F8>",
               F9 = "<F9>",
               F10 = "<F10>",
               F11 = "<F11>",
               F12 = "<F12>",
            },
         },

         -- Document existing key chains
         spec = {
            { "<leader>s", group = "[S]earch" },
            { "<leader>t", group = "[T]oggle" },
            { "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
         },

         win = {
            no_overlap = true,
            padding = { 0, 0 },
            title = true,
            title_pos = "center",
            zindex = 1000,
            border = "rounded",
            bo = {},
            wo = {},
         },
      },
   },

   -- Highlight todo, notes, etc in comments
   {
      "folke/todo-comments.nvim",
      event = "VimEnter",
      dependencies = { "nvim-lua/plenary.nvim" },
      opts = { signs = false },
   },
}
