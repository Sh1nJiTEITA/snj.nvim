return {
   "lewis6991/gitsigns.nvim",
   config = function()
      local module = require("gitsigns")
      module.setup({
         signs = {
            add = { text = "+" },
            change = { text = "~" },
            delete = { text = "_" },
            topdelete = { text = "‾" },
            changedelete = { text = "~" },
         },
         word_diff = false,
      })

      local toggleSigns = function()
         local vim_status = vim.opt.signcolumn:get()
         if vim_status == "yes" then
            vim.opt.signcolumn = "no"
            module.toggle_signs(false)
         else
            vim.opt.signcolumn = "yes"
            module.toggle_signs(true)
         end
      end
      -- disable signs at start (because its already enabled)
      -- toggleSigns()

      vim.keymap.set("n", "<leader>ts", toggleSigns, { desc = "[T]oggle git [S]ings" })

      -- show preview inside code of changed from last commit code
      vim.keymap.set("n", "<leader>pq", module.preview_hunk_inline, { desc = "[P]review hunk" })

      -- show panel on the left with history of git changes
      vim.keymap.set("n", "<leader>pB", module.blame, { desc = "[P]review [B]lame panel" })
      vim.keymap.set("n", "<leader>pb", module.blame_line, { desc = "[P]review [B]lame line" })
      vim.keymap.set("n", "<leader>pd", module.toggle_word_diff, { desc = "[P]review [D]iff inline" })
      vim.keymap.set("n", "<leader>pD", module.diffthis, { desc = "[P]review [D]iff" })
   end,
}
