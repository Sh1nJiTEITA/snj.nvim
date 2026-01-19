return { -- Highlight, edit, and navigate code
   -- {
   --    "nvim-treesitter/nvim-treesitter-context",
   --    opts = {
   --       multiwindow = true,
   --       mode = "topline",
   --       -- multiline_threshold = 2,
   --       -- zindex = 2,
   --       max_lines = 2,
   --       patterns = {
   --          cpp = {
   --             "class",
   --             "function",
   --             "method",
   --          },
   --       },
   --    },
   --    config = function(_, opts)
   --       require("treesitter-context").setup(opts)
   --       vim.keymap.set("n", "[c", function()
   --          require("treesitter-context").go_to_context(vim.v.count1)
   --       end, { silent = true })
   --    end,
   -- },
   {
      "nvim-treesitter/nvim-treesitter",
      -- commit = "f42378a9",
      commit = "42fc28ba",
      build = ":TSUpdate",
      main = "nvim-treesitter.configs", -- Sets main module to use for opts
      opts = {
         ensure_installed = {
            "latex",
            "bash",
            "c",
            "html",
            "glsl",
            "lua",
            "luadoc",
            "markdown",
            "vim",
            "vimdoc",
            "comment",
            "cpp",
            "doxygen",
            "markdown_inline",
         },
         -- Autoinstall languages that are not installed
         auto_install = true,
         highlight = {
            enable = true,
            additional_vim_regex_highlighting = { "ruby" },
         },
         indent = { enable = true, disable = { "ruby" } },
      },
      -- config = function(_, opts)
      --    require("nvim-treesitter.install").prefer_git = true
      --    ---@diagnostic disable-next-line: missing-fields
      --    require("nvim-treesitter.config").setup(opts)
      --    vim.filetype.add({
      --       vert = "glsl",
      --       frag = "glsl",
      --       geom = "glsl",
      --       comp = "glsl",
      --       tesse = "glsl",
      --       tessc = "glsl",
      --    })
      --
      --    --          vim.treesitter.query.set(
      --    --             "python",
      --    --             "injections",
      --    --             [[
      --    -- (
      --    --   (string_content) @injection.content
      --    --   (#match? @injection.content "```py")
      --    --   (#set! injection.language "python")
      --    -- )
      --    -- ]]
      -- end,
   },
   -- {
   --    "NvChad/nvim-colorizer.lua",
   --    -- config = function()
   --    -- require("colorizer").setup({
   --    opts = {
   --       RGB = true, -- #RGB hex codes
   --       RRGGBB = true, -- #RRGGBB hex codes
   --       names = false, -- "Name" codes like Blue or blue
   --       RRGGBBAA = false, -- #RRGGBBAA hex codes
   --       AARRGGBB = false, -- 0xAARRGGBB hex codes
   --       rgb_fn = false, -- CSS rgb() and rgba() functions
   --       hsl_fn = false, -- CSS hsl() and hsla() functions
   --       css = true, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
   --       css_fn = false, -- Enable all CSS *functions*: rgb_fn, hsl_fn
   --       -- Available modes for `mode`: foreground, background,  virtualtext
   --       mode = "foreground", -- Set the display mode.
   --       -- Available methods are false / true / "normal" / "lsp" / "both"
   --       -- True is same as normal
   --       tailwind = false, -- Enable tailwind colors
   --       -- parsers can contain values used in |user_default_options|
   --       sass = { enable = false, parsers = { "css" } }, -- Enable sass colors
   --       virtualtext = "■",
   --       -- update color values even if buffer is not focused
   --       -- example use: cmp_menu, cmp_docs
   --       always_update = true,
   --    },
   --    -- )
   --    -- end,
   -- },
}
