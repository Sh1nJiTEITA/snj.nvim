return {
	gh = "L3MON4D3/LuaSnip",
	deps = {
		{ gh = "rafamadriz/friendly-snippets" },
	},
	config = function()
		local ls = require("luasnip")
		local s, f = ls.snippet, ls.function_node

		ls.setup({
			history = true,
			updateevents = "TextChanged,TextChangedI",
		})

		require("luasnip.loaders.from_vscode").lazy_load() -- friendly-snippets + any vscode-style

		ls.add_snippets("all", {
			s(
				"date",
				f(function()
					return os.date("%Y-%m-%dT%H:%M:%S")
				end, {})
			),

			s(
				"datetz",
				f(function()
					return os.date("%Y-%m-%dT%H:%M:%S%z"):gsub("(%d%d)$", ":%1")
				end, {})
			),

			s(
				"dateutc",
				f(function()
					return os.date("!%Y-%m-%dT%H:%M:%SZ")
				end, {})
			),
		})

		-- expand / jump keymaps
		vim.keymap.set({ "i", "s" }, "<C-k>", function()
			if ls.expand_or_jumpable() then
				ls.expand_or_jump()
			end
		end, { desc = "Expand or jump snippet" })

		vim.keymap.set({ "i", "s" }, "<C-j>", function()
			if ls.jumpable(-1) then
				ls.jump(-1)
			end
		end, { desc = "Jump back in snippet" })

		vim.keymap.set("i", "<C-l>", function()
			if ls.choice_active() then
				ls.change_choice(1)
			end
		end, { desc = "Cycle choice node" })
	end,
}
