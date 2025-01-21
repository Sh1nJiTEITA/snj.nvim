return {
   -- {
   --    "Sh1nJiTEITA/lost.nvim",
   --    opts = {},
   --    priority = 1000,
   --    event = "VimEnter",
   -- },

   {
      "Sh1nJiTEITA/ashenbox.nvim",
      -- "ficcdaf/ashen.nvim",
      priority = 1000,
      event = "VimEnter",
      config = function()
         require("ashen").setup({
            terminal_colors = true,
            transparent = true,
            colors = {},
         })
         require("ashen").load()
         -- -- Прозрачность для окон и разделителей
         vim.cmd([[
            " highlight Normal guibg=NONE ctermbg=NONE
            " highlight NormalNC guibg=NONE ctermbg=NONE
            " highlight EndOfBuffer guibg=NONE ctermbg=NONE
            highlight WinSeparator guibg=NONE ctermbg=NONE
            highlight VertSplit guibg=NONE ctermbg=NONE
         ]])
      end,
   },

   -- {
   --    "ellisonleao/gruvbox.nvim",
   --    priority = 1000,
   --    event = "VimEnter",
   --    config = function()
   --       require("gruvbox").setup({
   --          terminal_colors = true, -- add neovim terminal colors
   --          undercurl = true,
   --          underline = true,
   --          bold = true,
   --          italic = {
   --             strings = true,
   --             emphasis = true,
   --             comments = true,
   --             operators = false,
   --             folds = true,
   --          },
   --          strikethrough = true,
   --          invert_selection = false,
   --          invert_signs = false,
   --          invert_tabline = false,
   --          invert_intend_guides = false,
   --          inverse = true, -- invert background for search, diffs, statuslines and errors
   --          contrast = "", -- can be "hard", "soft" or empty string
   --          palette_overrides = {},
   --          overrides = {},
   --          dim_inactive = false,
   --          transparent_mode = true,
   --       })
   --       vim.cmd("colorscheme gruvbox")
   --       -- vim.o.background = "dark"
   --       -- vim.o.background = "light"
   --    end,
   -- },

   -- {
   --    "catppuccin/nvim",
   --    name = "catppuccin",
   --    priority = 1000,
   --
   --    config = function()
   --       require("catppuccin").setup({
   --          flavour = "mocha",
   --          transparent_background = false,
   --          integrations = {
   --             treesitter = true,
   --             lsp_trouble = true,
   --             telescope = true,
   --             nvimtree = true,
   --             cmp = true,
   --             gitsigns = true,
   --          },
   --       })
   --       -- require("miasma").setup()
   --       -- vim.cmd("colorscheme catppuccin")
   --    end,
   -- },
   -- { -- You can easily change to a different colorscheme.
   --   -- Change the name of the colorscheme plugin below, and then
   --   -- change the command in the config to whatever the name of that colorscheme is.
   --   --
   --   -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
   --   'folke/tokyonight.nvim',
   --   --
   --   -- 'morhetz/gruvbox',
   --   priority = 1000, -- Make sure to load this before all the other start plugins.
   --   init = function()
   --     -- load the colorscheme here.
   --     -- like many other themes, this one has different styles, and you could load
   --     -- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
   --     vim.cmd.colorscheme 'tokyonight-moon'
   --
   --     -- vim.cmd.colorscheme 'gruvbox-dark'
   --     -- you can configure highlights by doing something like:
   --     vim.cmd.hi 'comment gui=none'
   --   end,
   -- },
}
