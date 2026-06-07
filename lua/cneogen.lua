return {
	gh = "danymat/neogen",
	config = function()
		local module = require("neogen")
		module.setup({})
		vim.keymap.set("n", "<Leader>ac", module.generate, { desc = "Generate annotation" })
	end,
}
