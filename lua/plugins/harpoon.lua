local function switch_current_header_source()
   local buf = vim.api.nvim_get_current_buf()

   -- Clangd
   local resp = vim.lsp.buf_request_sync(buf, "textDocument/switchSourceHeader", {
      uri = vim.uri_from_bufnr(buf),
   }, 50)

   if resp == nil then
      return
   end

   for _, data in pairs(resp) do
      if data.result then
         local buf = vim.uri_to_bufnr(data.result) or vim.api.nvim_get_current_buf()
         vim.api.nvim_set_current_buf(buf)
      end
   end
end

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
      end, { desc = "Add to Harpoon" })

      vim.keymap.set("n", "<leader>ad", function()
         harpoon:list():remove()
      end, {
         desc = "Delete from Harpoon",
      })

      vim.keymap.set("n", "<leader>g", function()
         harpoon.ui:toggle_quick_menu(harpoon:list())
      end, {
         desc = "Toggle Harpoon quick menu",
      })

      -- More smart switching logic for c/cpp files
      local switch = function(item_idx)
         -- If C++ or C -> Adding header <-> src files switch
         -- So less amount of files need to be stored inside harpoon list. Only
         -- headers can be stored
         if vim.bo.filetype == "c" or vim.bo.filetype == "cpp" then
            if item_idx > #harpoon:list().items then
               return
            end

            local project_dir = harpoon:list().config:get_root_dir()
            local after_path = harpoon:list():get(item_idx).value
            local full_path = vim.fn.fnamemodify(project_dir .. "/" .. after_path, ":p")
            local buf = vim.uri_to_bufnr(vim.uri_from_fname(full_path))
            local current_buf = vim.api.nvim_get_current_buf()
            -- If requesting buffer are the same as current:
            -- 1. Go to <*.h> (header) file if <*.cpp> (src) file selected
            -- 2. Viceversa
            if buf == current_buf then
               switch_current_header_source()
            else
               harpoon:list():select(item_idx)
            end
         else
            harpoon:list():select(item_idx)
         end
      end

      -- Adding select mappings
      for i = 1, 6 do
         local desc = "Select Harpoon buf " .. i
         vim.keymap.set("n", "<leader>" .. i, function()
            switch(i)
         end, { desc = desc })
      end

      -- Adding special auto header-src switch for any bound/nonbound to harpoon
      -- buf
      -- Works only for buffers attached to c/cpp filetypes
      vim.api.nvim_create_autocmd("FileType", {
         pattern = { "c", "cpp" },
         callback = function()
            local opts = { noremap = true, silent = true, buffer = true }
            vim.keymap.set("n", "<leader>0", function()
               switch_current_header_source()
            end, opts)
         end,
      })

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
