return {
   "ThePrimeagen/harpoon",
   branch = "harpoon2",
   dependencies = { "nvim-lua/plenary.nvim" },

   event = "VimEnter",
   config = function()
      local keymaps_module = require("keymaps")
      keymaps_module.init_harpoon_keymaps()
   end,
}
