return {
   "nvim-neo-tree/neo-tree.nvim",
   branch = "v3.x",
   dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
      "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
      "s1n7ax/nvim-window-picker",
   },
   opts = {
      window = {
         position = "left",
         width = 30,
         mapping_options = {
            noremap = true,
            nowait = true,
         },
      },
   },
}
