return {
	gh = "mikavilpas/yazi.nvim",
	config = function()
		local module = require("yazi")
		require("yazi").setup({})
		vim.keymap.set("n", "<leader>-", module.toggle, {
			desc = "Ppen yazi at the current file",
		})
	end,
}
