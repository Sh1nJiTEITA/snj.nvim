IsHarpoonMenuOpen = false

return {
   "ThePrimeagen/harpoon",
   branch = "harpoon2",
   dependencies = { "nvim-lua/plenary.nvim" },

   event = "VimEnter",
   config = function()
      local harpoon = require("harpoon")

      vim.keymap.set("n", "<leader>aa", function()
         harpoon:list():add()
      end, {
         desc = "Add to harpoon2",
      })

      vim.keymap.set("n", "<leader>ad", function()
         harpoon:list():remove()
      end, {
         desc = "Delete from Harpoon2",
      })

      vim.keymap.set("n", "<leader>0", function()
         harpoon.ui:toggle_quick_menu(harpoon:list())
      end, {
         desc = "Toggle harpoon2 quick menu",
      })

      vim.keymap.set("n", "<leader>1", function()
         harpoon:list():select(1)
      end, { desc = "Move harpoon2 => 1" })
      vim.keymap.set("n", "<leader>2", function()
         harpoon:list():select(2)
      end, { desc = "Move harpoon2 => 2" })
      vim.keymap.set("n", "<leader>3", function()
         harpoon:list():select(3)
      end, { desc = "Move harpoon2 => 3" })
      vim.keymap.set("n", "<leader>4", function()
         harpoon:list():select(4)
      end, { desc = "Move harpoon2 => 4" })

      -- Toggle previous & next buffers stored within Harpoon list
      vim.keymap.set("n", "<A-TAB>", function()
         harpoon:list():next()
      end, {
         desc = "Go next buffer via harpoon2",
      })
      vim.keymap.set("n", "<A-S-TAB>", function()
         harpoon:list():prev()
      end, {
         desc = "Go prev buffer via harpoon2",
      })
   end,
}
