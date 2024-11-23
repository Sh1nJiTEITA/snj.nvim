-- Remove highlight
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Diagnostic keymaps
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, {
   desc = "Go to previous [D]iagnostic message",
})

vim.keymap.set("n", "]d", vim.diagnostic.goto_next, {
   desc = "Go to next [D]iagnostic message",
})

vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, {
   desc = "Show diagnostic [E]rror messages",
})

vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, {
   desc = "Open diagnostic [Q]uickfix list",
})

vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

vim.keymap.set("n", "<left>", '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set("n", "<right>", '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set("n", "<up>", '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set("n", "<down>", '<cmd>echo "Use j to move!!"<CR>')

vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

--

-- vim.api.nvim_set_keymap("n", "<C-t>", ":NvimTreeToggle()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-t>", ":Neotree toggle<CR>", { noremap = true, silent = true })
vim.api.nvim_create_user_command("Wqa", "wqa", {})
vim.api.nvim_create_user_command("Wa", "wa", {})

-- Telescope

local M = {}

function M.init_telescope_keymaps(builtin)
   vim.keymap.set("n", "<leader>sh", builtin.help_tags, {
      desc = "[S]earch [H]elp",
   })

   vim.keymap.set("n", "<leader>sk", builtin.keymaps, {
      desc = "[S]earch [K]eymaps",
   })

   vim.keymap.set("n", "<leader>sf", builtin.find_files, {
      desc = "[S]earch [F]iles",
   })

   vim.keymap.set("n", "<leader>ss", builtin.builtin, {
      desc = "[S]earch [S]elect Telescope",
   })

   vim.keymap.set("n", "<leader>sw", builtin.grep_string, {
      desc = "[S]earch current [W]ord",
   })

   vim.keymap.set("n", "<leader>sg", builtin.live_grep, {
      desc = "[S]earch by [G]rep",
   })

   vim.keymap.set("n", "<leader>sd", builtin.diagnostics, {
      desc = "[S]earch [D]iagnostics",
   })

   vim.keymap.set("n", "<leader>sr", builtin.resume, {
      desc = "[S]earch [R]esume",
   })

   vim.keymap.set("n", "<leader>s.", builtin.oldfiles, {
      desc = '[S]earch Recent Files ("." for repeat)',
   })

   vim.keymap.set("n", "<leader><leader>", builtin.buffers, {
      desc = "[ ] Find existing buffers",
   })

   vim.keymap.set("n", "<leader>s/", function()
      builtin.live_grep({
         grep_open_files = true,
         prompt_title = "Live Grep in Open Files",
      })
   end, { desc = "[S]earch [/] in Open Files" })

   -- Shortcut for searching your Neovim configuration files
   vim.keymap.set("n", "<leader>sn", function()
      builtin.find_files({ cwd = vim.fn.stdpath("config") })
   end, { desc = "[S]earch [N]eovim files" })

   vim.keymap.set("n", "<leader>sq", function()
      builtin.buffers({
         attach_mappings = function(prompt_bufnr, map)
            local actions = require("telescope.actions")
            -- Mapping to close the selected buffer
            map("i", "<C-x>", function()
               local selection = require("telescope.actions.state").get_selected_entry()
               if selection then
                  vim.cmd("bdelete " .. selection.value)
                  actions.close(prompt_bufnr)
               end
            end)
            map("n", "<C-x>", function()
               local selection = require("telescope.actions.state").get_selected_entry()
               if selection then
                  vim.cmd("bdelete " .. selection.value)
                  actions.close(prompt_bufnr)
               end
            end)
            return true
         end,
      })
   end, { desc = "[S]earch and [Q]uit (close) selected buffer" })
end

-- LSP config

function M.init_lspconfig_keymaps(event, client)
   local map = function(keys, func, desc)
      vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
   end

   map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
   map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
   map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
   map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
   map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
   map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
   map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
   map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
   map("K", vim.lsp.buf.hover, "Hover Documentation")
   map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

   if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
      map("<leader>th", function()
         vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
      end, "[T]oggle Inlay [H]ints")
   end
end

-- which-key

function M.init_whichkey_keymaps()
   return {
      { "<leader>c", group = "[C]ode" },
      { "<leader>d", group = "[D]ocument" },
      { "<leader>r", group = "[R]ename" },
      { "<leader>s", group = "[S]earch" },
      { "<leader>w", group = "[W]orkspace" },
      { "<leader>t", group = "[T]oggle" },
      { "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
   }
end

function M.init_nvimcmp_keymaps()
   local cmp = require("cmp")
   local luasnip = require("luasnip")
   return cmp.mapping.preset.insert({
      ["<C-n>"] = cmp.mapping.select_next_item(),
      ["<C-p>"] = cmp.mapping.select_prev_item(),
      ["<C-b>"] = cmp.mapping.scroll_docs(-4),
      ["<C-f>"] = cmp.mapping.scroll_docs(4),
      ["<C-y>"] = cmp.mapping.confirm({ select = true }),
      ["<C-Space>"] = cmp.mapping.complete({}),

      ["<C-l>"] = cmp.mapping(function()
         if luasnip.expand_or_locally_jumpable() then
            luasnip.expand_or_jump()
         end
      end, { "i", "s" }),
      ["<C-h>"] = cmp.mapping(function()
         if luasnip.locally_jumpable(-1) then
            luasnip.jump(-1)
         end
      end, { "i", "s" }),
   })
end

-- harpoon2 --
IsHarpoonMenuOpen = false

function M.init_harpoon_keymaps()
   local harpoon = require("harpoon")

   vim.keymap.set("n", "<leader>aa", function()
      harpoon:list():add()
   end, {
      desc = "Add to Harpoon3",
   })

   vim.keymap.set("n", "<leader>ad", function()
      harpoon:list():remove()
   end, {
      desc = "Delete fron Harpoon3",
   })

   -- vim.keymap.set("n", "<leader>a", function()
   --    if IsHarpoonMenuOpen then
   --       local menu_index = harpoon.ui:select_menu_item()
   --       harpoon:list():remove(menu_index)
   --    end
   -- end, {
   --    desc = "Remove from Harpoon2",
   --    buffer = true,
   -- })

   vim.keymap.set("n", "<C-e>", function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
      IsHarpoonMenuOpen = not IsHarpoonMenuOpen
   end, {
      desc = "Toggle quick menu",
   })

   vim.keymap.set("n", "<M-1>", function()
      harpoon:list():select(1)
   end)
   vim.keymap.set("n", "<M-2>", function()
      harpoon:list():select(2)
   end)
   vim.keymap.set("n", "<M-3>", function()
      harpoon:list():select(3)
   end)
   vim.keymap.set("n", "<M-4>", function()
      harpoon:list():select(4)
   end)

   --
   -- Toggle previous & next buffers stored within Harpoon list
   -- vim.keymap.set("n", "<C-S-P>", function()
   --    harpoon:list():prev()
   -- end)
   -- vim.keymap.set("n", "<C-S-N>", function()
   --    harpoon:list():next()
   -- end)
end

return M
