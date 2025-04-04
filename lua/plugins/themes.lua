local function makeTransparent()
   vim.cmd([[
            highlight Normal guibg=NONE ctermbg=NONE
            highlight NormalNC guibg=NONE ctermbg=NONE
            highlight EndOfBuffer guifg=#AAAAAA ctermbg=NONE
            highlight WinSeparator guibg=NONE ctermbg=NONE
            highlight VertSplit guibg=NONE ctermbg=NONE
            highlight SignColumn guibg=NONE ctermbg=NONE
            highlight GitSignsAdd guibg=NONE ctermbg=NONE
            highlight GitSignsChange guibg=NONE ctermbg=NONE
            highlight GitSignsDelete guibg=NONE ctermbg=NONE
         ]])
end

local function initYankOnHighlight()
   vim.api.nvim_create_autocmd("TextYankPost", {
      desc = "Highlight when yanking (copying) text",
      group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
      callback = function()
         vim.highlight.on_yank()
      end,
   })
end

return {
   -- {
   --    "Sh1nJiTEITA/lost.nvim",
   --    opts = {},
   --    priority = 1000,
   --    event = "VimEnter",
   -- },

   {
      "rose-pine/neovim",
      name = "rose-pine",
      priority = 1000,
      event = "VimEnter",
      config = function()
         require("rose-pine").setup({
            variant = "auto", -- auto, main, moon, or dawn
            dark_variant = "main", -- main, moon, or dawn
            dim_inactive_windows = false,
            extend_background_behind_borders = true,

            enable = {
               terminal = true,
               legacy_highlights = true, -- Improve compatibility for previous versions of Neovim
               migrations = true, -- Handle deprecated options automatically
            },

            styles = {
               bold = true,
               italic = true,
               transparency = true,
            },

            groups = {
               border = "muted",
               link = "iris",
               panel = "surface",

               error = "love",
               hint = "iris",
               info = "foam",
               note = "pine",
               todo = "rose",
               warn = "gold",

               git_add = "foam",
               git_change = "rose",
               git_delete = "love",
               git_dirty = "rose",
               git_ignore = "muted",
               git_merge = "iris",
               git_rename = "pine",
               git_stage = "iris",
               git_text = "rose",
               git_untracked = "subtle",

               h1 = "iris",
               h2 = "foam",
               h3 = "rose",
               h4 = "gold",
               h5 = "pine",
               h6 = "foam",
            },
         })
         vim.cmd("colorscheme rose-pine")
         initYankOnHighlight()
      end,
   },

   {
      "Sh1nJiTEITA/ashenbox.nvim",
      -- "ficcdaf/ashen.nvim",
      -- priority = 1000,
      -- event = "VimEnter",
      config = function()
         require("ashen").setup({
            terminal_colors = true,
            -- transparent = true,
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

   {
      "slugbyte/lackluster.nvim",
      -- lazy = false,
      -- priority = 1000,
      init = function()
         -- vim.cmd.colorscheme("lackluster")
         -- vim.cmd.colorscheme("lackluster-hack") -- my favorite
         vim.cmd.colorscheme("lackluster-mint")
         -- makeTransparent()
      end,
   },

   {
      "ellisonleao/gruvbox.nvim",
      -- priority = 1000,
      -- event = "VimEnter",
      config = function()
         require("gruvbox").setup({
            terminal_colors = true, -- add neovim terminal colors
            undercurl = true,
            underline = true,
            bold = true,
            italic = {
               strings = true,
               emphasis = true,
               comments = true,
               operators = false,
               folds = true,
            },
            strikethrough = true,
            invert_selection = false,
            invert_signs = false,
            invert_tabline = false,
            invert_intend_guides = false,
            inverse = true, -- invert background for search, diffs, statuslines and errors
            contrast = "soft", -- can be "hard", "soft" or empty string
            palette_overrides = {},
            overrides = {},
            dim_inactive = false,
            transparent_mode = true,
         })
         vim.cmd("colorscheme gruvbox")
      end,
   },

   {
      "catppuccin/nvim",
      name = "catppuccin",
      -- priority = 1000,

      config = function()
         require("catppuccin").setup({
            flavour = "mocha",
            transparent_background = false,
            integrations = {
               treesitter = true,
               lsp_trouble = true,
               telescope = true,
               nvimtree = true,
               cmp = true,
               gitsigns = true,
            },
         })
         -- makeTransparent()
         -- require("miasma").setup()
         -- vim.cmd("colorscheme catppuccin")
      end,
   },
   { -- You cat easily change to a different colorscheme.
      -- Change the name of the colorscheme plugin below, and then
      -- change the command in the config to whatever the name of that colorscheme is.
      --
      -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
      "folke/tokyonight.nvim",
      --
      -- 'morhetz/gruvbox',
      -- priority = 1000, -- Make sure to load this before all the other start plugins.
      init = function()
         -- load the colorscheme here.
         -- like many other themes, this one has different styles, and you could load
         -- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
         vim.cmd.colorscheme("tokyonight-moon")

         -- vim.cmd.colorscheme 'gruvbox-dark'
         -- you can configure highlights by doing something like:
         vim.cmd.hi("comment gui=none")
         -- makeTransparent()
      end,
   },
}
