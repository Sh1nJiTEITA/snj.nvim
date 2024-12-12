return {
   {
      "danymat/neogen",
      config = true,
      -- Uncomment next line if you want to follow only stable versions
      -- version = "*"
   },
   { "xiyaowong/transparent.nvim" },
   { "tpope/vim-sleuth" },

   {
      "lewis6991/gitsigns.nvim",
      opts = {
         signs = {
            add = { text = "+" },
            change = { text = "~" },
            delete = { text = "_" },
            topdelete = { text = "‾" },
            changedelete = { text = "~" },
         },
      },
   },

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
         require("which-key").setup()
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
}
