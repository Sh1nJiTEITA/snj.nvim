return {
   "nvim-telescope/telescope.nvim",
   event = "VimEnter",
   branch = "0.1.x",
   dependencies = {
      "nvim-lua/plenary.nvim",
      {
         "nvim-telescope/telescope-fzf-native.nvim",
         build = "make",
         cond = function()
            return vim.fn.executable("make") == 1
         end,
      },
      { "nvim-telescope/telescope-ui-select.nvim" },
      { "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
      {
         "andrew-george/telescope-themes",
         config = function()
            vim.keymap.set("n", "<leader>st", ":Telescope themes<CR>", {
               desc = "[S]earch [T]hemes",
               noremap = true,
               silent = true,
            })
         end,
      },
   },
   config = function()
      require("telescope").setup({
         extensions = {
            ["ui-select"] = {
               require("telescope.themes").get_dropdown(),
            },
         },
         pickers = {
            find_files = {
               hidden = true,
            },
         },
         defaults = {
            file_ignore_patterns = {
               ".git/.*",
               ".github/.*",
               ".*external/.*",
            },
         },
      })

      -- Enable Telescope extensions if they are installed
      pcall(require("telescope").load_extension, "fzf")
      pcall(require("telescope").load_extension, "ui-select")
      pcall(require("telescope").load_extension, "themes")

      require("keymaps").init_telescope_keymaps(require("telescope.builtin"))
   end,
}
