local function client_supports_method(client, method, bufnr)
	local is_011 = (vim.fn.has("nvim-0.11") == 1)
	if is_011 then
		return client:supports_method(method, bufnr)
	end
	return client.supports_method(method, { bufnr = bufnr })
end

local function lsp_keymaps(bufnr)
	local map = function(keys, func, desc)
		vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
	end

	map("K", function()
		local dap = require("dap")
		if dap.session() then
			require("dapui").eval()
		else
			vim.lsp.buf.hover({ border = "rounded" })
		end
	end, "Smart Hover (LSP or DAP)")

	map("grn", vim.lsp.buf.rename, "Rename")
	map("gra", vim.lsp.buf.code_action, "Action")
	map("grr", require("telescope.builtin").lsp_references, "References")
	map("gri", require("telescope.builtin").lsp_implementations, "Implementation")
	map("grd", require("telescope.builtin").lsp_definitions, "Definition")
	map("gd", vim.lsp.buf.definition, "Definition")
	map("gO", require("telescope.builtin").lsp_document_symbols, "Symbols")
end

-- 2. Optimized Highlighting (No leaks)
local function lsp_highlighting(client, bufnr)
	if client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, bufnr) then
		-- Use bufnr in the name to keep groups isolated
		local group = vim.api.nvim_create_augroup("lsp-highlight-" .. bufnr, { clear = true })

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

		-- Cleanup when LSP leaves this specific buffer
		vim.api.nvim_create_autocmd("LspDetach", {
			buffer = bufnr,
			callback = function()
				vim.lsp.buf.clear_references()
				vim.api.nvim_clear_autocmds({ group = group, buffer = bufnr })
			end,
		})
	end
end

return {
	{ "folke/lazydev.nvim", ft = "lua", opts = {} },
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{ "williamboman/mason.nvim", config = true },
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			{ "j-hui/fidget.nvim", opts = {} },
			"Saghen/blink.cmp",
		},
		config = function()
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
				callback = function(event)
					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if not client then
						return
					end

					lsp_keymaps(event.buf)
					lsp_highlighting(client, event.buf)

					-- Inlay Hints (0.10+)
					-- if client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
					--    vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
					-- end
				end,
			})

			-- High performance Diagnostic Config (Static)
			vim.diagnostic.config({
				severity_sort = true,
				float = { border = "rounded" },
				underline = { severity = vim.diagnostic.severity.ERROR },
				virtual_text = { prefix = "●", spacing = 4 },
				signs = {
					text = {
						[vim.diagnostic.severity.ERROR] = "󰅚 ",
						[vim.diagnostic.severity.WARN] = "󰀪 ",
						[vim.diagnostic.severity.INFO] = "󰋽 ",
						[vim.diagnostic.severity.HINT] = "󰌶 ",
					},
				},
			})

			local capabilities = require("blink.cmp").get_lsp_capabilities()
			local servers = {
				clangd = {
					-- Command line flags to make clangd smoother
					cmd = {
						"clangd",
						"--background-index",
						"--clang-tidy",
						"--header-insertion=iwyu",
						"--completion-style=detailed",
						"--function-arg-placeholders",
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
				pyright = { settings = { python = { analysis = { autoImportCompletions = true } } } },

				vtsls = {},
				vtsls = {
					filetypes = {
						"javascript",
						"javascriptreact",
						"javascript.jsx",
						"typescript",
						"typescriptreact",
						"typescript.tsx",
						"vue",
					},
					settings = {
						vtsls = {
							tsserver = {
								globalPlugins = {
									{
										name = "@vue/typescript-plugin",
										location = vim.fn.stdpath("data")
											.. "/mason/packages/vue-language-server/node_modules/@vue/language-server",
										languages = { "vue" },
									},
								},
							},
						},
					},
				},

				bashls = {},
			}

			require("mason-tool-installer").setup({
				ensure_installed = vim.list_extend(vim.tbl_keys(servers), {
					"stylua",
					"ruff",
					"shfmt",
					"shellcheck",
				}),
			})

			require("mason-lspconfig").setup({
				handlers = {
					function(server_name)
						local server = servers[server_name] or {}
						server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
						require("lspconfig")[server_name].setup(server)
					end,
				},
			})
		end,
	},

	{
		"saghen/blink.cmp",
		version = "1.*",
		opts = {
			keymap = { preset = "default" },
			appearance = { nerd_font_variant = "mono" },
			completion = {
				menu = { border = "rounded" },
				documentation = { auto_show = true, window = { border = "rounded" } },
			},
			signature = { enabled = true, window = { border = "rounded" } },
		},
	},
}
