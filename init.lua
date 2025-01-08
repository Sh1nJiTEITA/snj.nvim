require("vim_options")
require("autocmd")
require("lazy").setup({
   require("plugins.dap"),
   require("plugins.lazygit"),
   require("plugins.neo-tree"),
   require("plugins.harpoon"),
   require("plugins.other"),
   require("plugins.telescope"),
   require("plugins.lsp"),
   require("plugins.conform"),
   require("plugins.themes"),
   require("plugins.mini"),
   require("plugins.treesitter"),
   -- require("plugins.self"),
   require("plugins.obsidian"),
}, {
   ui = {
      icons = vim.g.have_nerd_font and {} or {
         cmd = "",
         config = "",
         event = "",
         ft = "",
         init = "",
         plugin = "",
         runtime = "",
         require = "",
         source = "",
         start = "北",
         task = "",
         lazy = "鈴",
      },
   },
})
