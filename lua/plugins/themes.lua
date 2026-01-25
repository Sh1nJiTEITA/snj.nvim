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
            highlight TreesitterContext guibg=#1f2335)
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

   -- {
   --    "rebelot/kanagawa.nvim",
   -- },

   -- {
   --    "thesimonho/kanagawa-paper.nvim",
   --    lazy = false,
   --    priority = 1000,
   --    opts = {
   --       -- enable undercurls for underlined text
   --       undercurl = true,
   --       -- transparent background
   --       transparent = true,
   --       -- highlight background for the left gutter
   --       gutter = false,
   --       -- background for diagnostic virtual text
   --       diag_background = true,
   --       -- dim inactive windows. Disabled when transparent
   --       dim_inactive = false,
   --       -- set colors for terminal buffers
   --       terminal_colors = true,
   --       -- cache highlights and colors for faster startup.
   --       -- see Cache section for more details.
   --       cache = false,
   --
   --       styles = {
   --          -- style for comments
   --          comment = { italic = true },
   --          -- style for functions
   --          functions = { italic = false },
   --          -- style for keywords
   --          keyword = { italic = false, bold = false },
   --          -- style for statements
   --          statement = { italic = false, bold = false },
   --          -- style for types
   --          type = { italic = false },
   --       },
   --       -- override default palette and theme colors
   --       colors = {
   --          palette = {},
   --          theme = {
   --             ink = {},
   --             canvas = {},
   --          },
   --       },
   --       -- adjust overall color balance for each theme [-1, 1]
   --       color_offset = {
   --          ink = { brightness = 0, saturation = 0 },
   --          canvas = { brightness = 0, saturation = 0 },
   --       },
   --       -- override highlight groups
   --       overrides = function(colors)
   --          return {}
   --       end,
   --
   --       -- uses lazy.nvim, if installed, to automatically enable needed plugins
   --       auto_plugins = true,
   --       -- enable highlights for all plugins (disabled if using lazy.nvim)
   --       all_plugins = package.loaded.lazy == nil,
   --       -- manually enable/disable individual plugins.
   --       -- check the `groups/plugins` directory for the exact names
   --       plugins = {
   --          -- examples:
   --          -- rainbow_delimiters = true
   --          -- which_key = false
   --       },
   --    },
   --    config = function(_, opts)
   --       local theme = require("kanagawa-paper")
   --       theme.setup(opts)
   --       initYankOnHighlight()
   --       vim.cmd.colorscheme("kanagawa-paper-ink")
   --    end,
   -- },

   -- {
   --    "rose-pine/neovim",
   --    name = "rose-pine",
   --    priority = 1000,
   --    event = "VimEnter",
   --    config = function()
   --       require("rose-pine").setup({
   --          variant = "auto", -- auto, main, moon, or dawn
   --          dark_variant = "main", -- main, moon, or dawn
   --          dim_inactive_windows = false,
   --          extend_background_behind_borders = true,
   --
   --          enable = {
   --             terminal = true,
   --             legacy_highlights = true, -- Improve compatibility for previous versions of Neovim
   --             migrations = true, -- Handle deprecated options automatically
   --          },
   --
   --          styles = {
   --             bold = true,
   --             italic = true,
   --             transparency = true,
   --          },
   --
   --          groups = {
   --             border = "muted",
   --             link = "iris",
   --             panel = "surface",
   --
   --             error = "love",
   --             hint = "iris",
   --             info = "foam",
   --             note = "pine",
   --             todo = "rose",
   --             warn = "gold",
   --
   --             git_add = "foam",
   --             git_change = "rose",
   --             git_delete = "love",
   --             git_dirty = "rose",
   --             git_ignore = "muted",
   --             git_merge = "iris",
   --             git_rename = "pine",
   --             git_stage = "iris",
   --             git_text = "rose",
   --             git_untracked = "subtle",
   --
   --             h1 = "iris",
   --             h2 = "foam",
   --             h3 = "rose",
   --             h4 = "gold",
   --             h5 = "pine",
   --             h6 = "foam",
   --          },
   --       })
   --       vim.cmd.colorscheme("rose-pine")
   --       vim.api.nvim_set_hl(0, "TreesitterContextBottom", {
   --          underline = true,
   --          sp = "#c4a7e7", -- your desired underline color
   --          fg = "NONE",
   --          bg = "NONE",
   --       })
   --       initYankOnHighlight()
   --       -- vim.cmd("highlight DapStoppedLine guibg=#3c3836 gui=underline")
   --       vim.schedule(function()
   --          vim.api.nvim_set_hl(0, "DapStoppedLine", {
   --             bg = "#3c3836",
   --             underline = true,
   --          })
   --       end)
   --    end,
   -- },

   -- {
   --    "Sh1nJiTEITA/ashenbox.nvim",
   --    -- "ficcdaf/ashen.nvim",
   --    -- priority = 1000,
   --    -- event = "VimEnter",
   --    config = function()
   --       require("ashen").setup({
   --          terminal_colors = true,
   --          -- transparent = true,
   --          colors = {},
   --       })
   --       require("ashen").load()
   --       -- -- Прозрачность для окон и разделителей
   --       vim.cmd([[
   --          " highlight Normal guibg=NONE ctermbg=NONE
   --          " highlight NormalNC guibg=NONE ctermbg=NONE
   --          " highlight EndOfBuffer guibg=NONE ctermbg=NONE
   --          highlight WinSeparator guibg=NONE ctermbg=NONE
   --          highlight VertSplit guibg=NONE ctermbg=NONE
   --       ]])
   --    end,
   -- },

   -- {
   --    "slugbyte/lackluster.nvim",
   --    -- lazy = false,
   --    -- priority = 1000,
   --    init = function()
   --       -- vim.cmd.colorscheme("lackluster")
   --       -- vim.cmd.colorscheme("lackluster-hack") -- my favorite
   --       vim.cmd.colorscheme("lackluster-mint")
   --       -- makeTransparent()
   --    end,
   -- },
   --
   -- {
   --    "ellisonleao/gruvbox.nvim",
   --    -- priority = 1000,
   --    -- event = "VimEnter",
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
   --          contrast = "soft", -- can be "hard", "soft" or empty string
   --          palette_overrides = {},
   --          overrides = {},
   --          dim_inactive = false,
   --          transparent_mode = true,
   --       })
   --       vim.cmd("colorscheme gruvbox")
   --    end,
   -- },
   --
   -- {
   --    "catppuccin/nvim",
   --    name = "catppuccin",
   --    -- priority = 1000,
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
   --       -- makeTransparent()
   --       -- require("miasma").setup()
   --       -- vim.cmd("colorscheme catppuccin")
   --    end,
   -- },
   { -- You cat easily change to a different colorscheme.
      "folke/tokyonight.nvim",
      priority = 999, -- Make sure to load this before all the other start plugins.
      event = "VimEnter",
      lazy = false,
      opts = {
         style = "night", -- The theme comes in three styles, `storm`, a darker variant `night` and `day`
         light_style = "day", -- The theme is used when the background is set to light
         transparent = true, -- Enable this to disable setting the background color
         tokyonight_dark_float = false,
         terminal_colors = true, -- Configure the colors used when opening a `:terminal` in Neovim
         styles = {
            comments = { italic = true },
            keywords = { italic = true },
            functions = {},
            variables = {},
            sidebars = "transparent", -- style for sidebars, see below
            floats = "transparent", -- style for floating windows
         },
         day_brightness = 0.3, -- Adjusts the brightness of the colors of the **Day** style. Number between 0 and 1, from dull to vibrant colors
         dim_inactive = false, -- dims inactive windows
         lualine_bold = false, -- When `true`, section headers in the lualine theme will be bold

         --- You can override specific color groups to use other groups or a hex color
         --- function will be called with a ColorScheme table
         ---@param colors ColorScheme
         on_colors = function(colors) end,

         --- You can override specific highlights to use other groups or a hex color
         --- function will be called with a Highlights and ColorScheme table
         ---@param highlights tokyonight.Highlights
         ---@param colors ColorScheme
         on_highlights = function(highlights, colors) end,

         cache = true, -- When set to true, the theme will be cached for better performance

         ---@type table<string, boolean|{enabled:boolean}>
         plugins = {
            all = package.loaded.lazy == nil,
            auto = true,
         },
      },
      config = function(_, opts)
         local theme = require("tokyonight")
         theme.setup(opts)
         initYankOnHighlight()
         vim.cmd.colorscheme("tokyonight")
      end,
   },
}
