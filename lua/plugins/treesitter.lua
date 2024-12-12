return { -- Highlight, edit, and navigate code
   {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      opts = {
         ensure_installed = {
            "bash",
            "c",
            "html",
            "lua",
            "luadoc",
            "markdown",
            "vim",
            "vimdoc",
            "comment",
            "cpp",
            "doxygen",
         },
         -- Autoinstall languages that are not installed
         auto_install = true,
         highlight = {
            enable = true,
            additional_vim_regex_highlighting = { "ruby" },
         },
         indent = { enable = true, disable = { "ruby" } },
      },
      config = function(_, opts)
         require("nvim-treesitter.install").prefer_git = true
         ---@diagnostic disable-next-line: missing-fields
         require("nvim-treesitter.configs").setup(opts)
      end,
   },
   {
      "NvChad/nvim-colorizer.lua",
      -- config = function()
      -- require("colorizer").setup({
      opts = {
         RGB = true, -- #RGB hex codes
         RRGGBB = true, -- #RRGGBB hex codes
         names = false, -- "Name" codes like Blue or blue
         RRGGBBAA = false, -- #RRGGBBAA hex codes
         AARRGGBB = false, -- 0xAARRGGBB hex codes
         rgb_fn = false, -- CSS rgb() and rgba() functions
         hsl_fn = false, -- CSS hsl() and hsla() functions
         css = true, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
         css_fn = false, -- Enable all CSS *functions*: rgb_fn, hsl_fn
         -- Available modes for `mode`: foreground, background,  virtualtext
         mode = "foreground", -- Set the display mode.
         -- Available methods are false / true / "normal" / "lsp" / "both"
         -- True is same as normal
         tailwind = false, -- Enable tailwind colors
         -- parsers can contain values used in |user_default_options|
         sass = { enable = false, parsers = { "css" } }, -- Enable sass colors
         virtualtext = "■",
         -- update color values even if buffer is not focused
         -- example use: cmp_menu, cmp_docs
         always_update = true,
      },
      -- )
      -- end,
   },
}
