return {
	gh = "nvim-neo-tree/neo-tree.nvim",
	deps = {
		{ gh = "nvim-lua/plenary.nvim" },
		{ gh = "MunifTanjim/nui.nvim" },
		{ gh = "nvim-tree/nvim-web-devicons" },
	},

	config = function()
		local mod = require("neo-tree")

		vim.keymap.set("n", "<C-t>", function()
			vim.cmd("Neotree toggle")
		end, { desc = "[T]oggle neotree" })

		mod.setup({})
	end,
}
