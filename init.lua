require("vim_options")
require("autocmd")
-- require("tex_launch")

require("lazy").setup({
   -- require("plugins.snacks"),
   -- require("plugins.dap"),
   -- require("plugins.lazygit"),
   -- require("plugins.neo-tree"),
   require("plugins.other"),
   require("plugins.gitsigns"),
   require("plugins.telescope"),
   require("plugins.lsp"),
   require("plugins.conform"),
   require("plugins.themes"),
   require("plugins.mini"),
   require("plugins.treesitter"),
   -- require("plugins.self"),
   -- require("plugins.obsidian"),
   require("plugins.yazi"),
   require("plugins.harpoon"),
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
         source = " ",
         start = "北",
         task = "",
         lazy = "鈴",
      },
   },
})
