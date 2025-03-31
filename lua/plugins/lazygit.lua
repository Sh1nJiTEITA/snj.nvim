return {
   "kdheepak/lazygit.nvim",
   lazy = false,
   cmd = {
      "LazyGit",

      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
   },
   dependencies = {
      "nvim-telescope/telescope.nvim",
      "nvim-lua/plenary.nvim",
   },
   config = function()
      require("telescope").load_extension("lazygit")

      -- local lazygit_toggle = function()
      --    -- Ищем буфер LazyGit
      --    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      --       if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_get_option(buf, "filetype") == "lazygit" then
      --          -- Если LazyGit открыт, закрываем его
      --          vim.api.nvim_buf_delete(buf, { force = true })
      --          return
      --       end
      --    end
      --
      --    -- Если LazyGit не найден, открываем
      --    vim.cmd("LazyGit")
      -- end
      --
      -- -- Привязка клавиши для открытия/закрытия LazyGit
      -- vim.keymap.set("n", "<C-l>", lazygit_toggle, { desc = "Toggle LazyGit", noremap = true, silent = true })
   end,
   keys = {
      { "<leader>ll", "<cmd>LazyGit<cr>", desc = "LazyGit" },
   },
}
