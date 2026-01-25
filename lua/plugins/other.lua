return {

   {
      "kiyoon/jupynium.nvim",
      -- build = "sudo pacman -S python-jupynium", -- FIXME: Not working on ARCH
      config = function()
         require("jupynium").setup({})
         vim.keymap.set("n", "<leader>jr", function()
            vim.cmd("JupyniumStartAndAttachToServer")
         end, { desc = "[j]upynium s[r]tart" })

         vim.keymap.set("n", "<leader>jsy", function()
            vim.cmd("JupyniumStartSync")
         end, { desc = "[j]upynium [s][y]nc" })

         vim.keymap.set("n", "<leader>jss", function()
            vim.cmd("JupyniumStopSync")
         end, { desc = "[j]upynium [s]top [s]ync" })
      end,
   },

   {
      "dstein64/vim-startuptime",
   },

   {
      "folke/which-key.nvim",
      event = "VimEnter",
      opts = {
         delay = 500,
         icons = {
            mappings = vim.g.have_nerd_font,
            keys = vim.g.have_nerd_font and {} or {
               Up = "<Up> ",
               Down = "<Down> ",
               Left = "<Left> ",
               Right = "<Right> ",
               C = "<C-…> ",
               M = "<M-…> ",
               D = "<D-…> ",
               S = "<S-…> ",
               CR = "<CR> ",
               Esc = "<Esc> ",
               ScrollWheelDown = "<ScrollWheelDown> ",
               ScrollWheelUp = "<ScrollWheelUp> ",
               NL = "<NL> ",
               BS = "<BS> ",
               Space = "<Space> ",
               Tab = "<Tab> ",
               F1 = "<F1>",
               F2 = "<F2>",
               F3 = "<F3>",
               F4 = "<F4>",
               F5 = "<F5>",
               F6 = "<F6>",
               F7 = "<F7>",
               F8 = "<F8>",
               F9 = "<F9>",
               F10 = "<F10>",
               F11 = "<F11>",
               F12 = "<F12>",
            },
         },

         -- Document existing key chains
         spec = {
            { "<leader>s", group = "[S]earch" },
            { "<leader>t", group = "[T]oggle" },
            { "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
         },

         win = {
            no_overlap = true,
            padding = { 0, 0 },
            title = true,
            title_pos = "center",
            zindex = 1000,
            border = "rounded",
            bo = {},
            wo = {},
         },
      },
   },

   -- Highlight todo, notes, etc in comments
   {
      "folke/todo-comments.nvim",
      event = "VimEnter",
      dependencies = { "nvim-lua/plenary.nvim" },
      opts = { signs = false },
   },
}
