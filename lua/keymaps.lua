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

return M
