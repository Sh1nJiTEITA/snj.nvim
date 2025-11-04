IsHarpoonMenuOpen = false

-- local conf = require("telescope.config").values
-- local function toggle_telescope(harpoon_files)
--    local file_paths = {}
--    for _, item in ipairs(harpoon_files.items) do
--       table.insert(file_paths, item.value)
--    end
--
--    require("telescope.pickers")
--       .new({}, {
--          prompt_title = "Harpoon",
--          finder = require("telescope.finders").new_table({
--             results = file_paths,
--          }),
--          previewer = conf.file_previewer({}),
--          sorter = conf.generic_sorter({}),
--       })
--       :find()
-- end

return {
   "ThePrimeagen/harpoon",
   branch = "harpoon2",
   dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
   },

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

      vim.keymap.set("n", "<leader>5", function()
         harpoon:list():select(5)
      end, { desc = "Move harpoon2 => 5" })

      vim.keymap.set("n", "<leader>6", function()
         harpoon:list():select(6)
      end, { desc = "Move harpoon2 => 6" })

      -- vim.keymap.set("n", "<leader>7", function()
      --    harpoon:list():select(7)
      -- end, { desc = "Move harpoon2 => 7" })

      -- vim.keymap.set("n", "<leader>8", function()
      --    harpoon:list():select(8)
      -- end, { desc = "Move harpoon2 => 8" })

      -- vim.keymap.set("n", "<leader>9", function()
      --    harpoon:list():select(9)
      -- end, { desc = "Move harpoon2 => 9" })

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

      -- vim.keymap.set(
      --    "n",
      --    "<leader>j",
      --    toggle_telescope(harpoon:list())({
      --       desc = "Open harpoon2 list",
      --    })
      -- )
      local conf = require("telescope.config").values
      local function toggle_telescope(harpoon_files)
         local file_paths = {}
         for _, item in ipairs(harpoon_files.items) do
            table.insert(file_paths, item.value)
         end

         require("telescope.pickers")
            .new({}, {
               prompt_title = "Harpoon",
               finder = require("telescope.finders").new_table({
                  results = file_paths,
               }),
               previewer = conf.file_previewer({}),
               sorter = conf.generic_sorter({}),
            })
            :find()
      end

      vim.keymap.set("n", "<C-e>", function()
         toggle_telescope(harpoon:list())
      end, { desc = "Open harpoon window" })
   end,
}
