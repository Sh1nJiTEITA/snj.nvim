return { -- Highlight, edit, and navigate code

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
   },
}
