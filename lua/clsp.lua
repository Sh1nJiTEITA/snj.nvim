local map = function(keys, func, desc)
	vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
end

local setup_lsp_keymaps = function(bufnr)
	map("K", function()
		local dap = require("dap")
		if dap.session() then
			require("dapui").eval()
		else
			vim.lsp.buf.hover({ border = "rounded" })
		end
	end, "Smart Hover (LSP or DAP)")

	map("gd", vim.lsp.buf.definition, "Definition")
	map("grn", vim.lsp.buf.rename, "Rename")
	map("gra", vim.lsp.buf.code_action, "Action")
	map("grr", require("telescope.builtin").lsp_references, "References")
	map("gri", require("telescope.builtin").lsp_implementations, "Implementation")
	map("grd", require("telescope.builtin").lsp_definitions, "Definition")
	map("gO", require("telescope.builtin").lsp_document_symbols, "Symbols")
end

local setup_lsp_highlight = function(client, bufnr)
	if client and client:supports_method("textDocument/documentHighlight", bufnr) then
		local group = vim.api.nvim_create_augroup("lsp-highlight" .. bufnr, { clear = false })

		vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
			buffer = bufnr,
			group = group,
			callback = vim.lsp.buf.document_highlight,
		})

		vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
			buffer = bufnr,
			group = group,
			callback = vim.lsp.buf.clear_references,
		})

		vim.api.nvim_create_autocmd("LspDetach", {
			group = vim.api.nvim_create_augroup("lsp-detach", { clear = true }),
			callback = function(event2)
				vim.lsp.buf.clear_references()
				vim.api.nvim_clear_autocmds({ group = group, buffer = event2.buf })
			end,
		})
	end
end

local setup_lsp_inline = function(client, bufnr)
	if client and client:supports_method("textDocument/inlayHint", bufnr) then
		map("<leader>th", function()
			vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }))
		end, "[T]oggle Inlay [H]ints")
	end
end

local setup_lsp_attach = function()
	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
		callback = function(event)
			local client = vim.lsp.get_client_by_id(event.data.client_id)
			setup_lsp_keymaps(event.buf)
			setup_lsp_highlight(client, event.buf)
			setup_lsp_inline(client, event.buf)
		end,
	})
end

local setup_diagnostics = function()
	vim.diagnostic.config({
		update_in_insert = false,
		severity_sort = true,
		float = { border = "rounded", source = "if_many" },
		underline = { severity = vim.diagnostic.severity.ERROR },
		virtual_text = { prefix = "●", spacing = 4 },
		virtual_lines = false, -- Text shows up underneath the line, with virtual lines
		signs = {
			text = {
				[vim.diagnostic.severity.ERROR] = "󰅚 ",
				[vim.diagnostic.severity.WARN] = "󰀪 ",
				[vim.diagnostic.severity.INFO] = "󰋽 ",
				[vim.diagnostic.severity.HINT] = "󰌶 ",
			},
		},
		jump = {
			on_jump = function(_, bufnr)
				vim.diagnostic.open_float({
					bufnr = bufnr,
					scope = "cursor",
					focus = false,
				})
			end,
		},
	})
end

local setup_servers = function(servers)
	local ensure_installed = vim.tbl_keys(servers or {})
	local installer = require("mason-tool-installer")
	installer.setup({ ensure_installed = ensure_installed })
	for name, server in pairs(servers) do
		vim.lsp.config(name, server)
		vim.lsp.enable(name)
	end
end

return {
	gh = "neovim/nvim-lspconfig",
	deps = {
		{ gh = "williamboman/mason.nvim", config = {} },
		{ gh = "williamboman/mason-lspconfig.nvim" },
		{ gh = "WhoIsSethDaniel/mason-tool-installer.nvim", config = {} },
	},
	config = function()
		setup_lsp_attach()
		setup_diagnostics()
		setup_servers({

			stylua = {},
			ruff = {},
			shfmt = {},
			shellcheck = {},

			clangd = {
				-- Command line flags to make clangd smoother
				cmd = {
					"clangd",
					"--background-index",
					"--clang-tidy",
					"--header-insertion=iwyu",
					"--completion-style=detailed",
					"--function-arg-placeholders=1",
				},
			},
			lua_ls = {
				settings = {
					Lua = {
						completion = { callSnippet = "Replace" },
						diagnostics = {
							globals = { "vim" },
						},
						workspace = {
							-- Make the server aware of Neovim runtime files
							library = vim.api.nvim_get_runtime_file("", true),
							checkThirdParty = false,
						},
					},
				},
			},
		})
	end,
}
