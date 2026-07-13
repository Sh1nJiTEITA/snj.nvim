return {
	gh = "rose-pine/neovim",
	alias = "rose-pine",
	config = function()
		-- 1. Query the system for the current GTK color scheme

		require("rose-pine").setup({
			variant = "auto", -- auto, main, moon, or dawn
			dark_variant = "main", -- main, moon, or dawn
			dim_inactive_windows = false,
			extend_background_behind_borders = true,

			enable = {
				terminal = true,
				legacy_highlights = true, -- Improve compatibility for previous versions of Neovim
				migrations = true, -- Handle deprecated options automatically
			},

			styles = {
				bold = true,
				italic = true,
				transparency = true,
			},

			groups = {
				border = "muted",
				link = "iris",
				panel = "surface",

				error = "love",
				hint = "iris",
				info = "foam",
				note = "pine",
				todo = "rose",
				warn = "gold",

				git_add = "foam",
				git_change = "rose",
				git_delete = "love",
				git_dirty = "rose",
				git_ignore = "muted",
				git_merge = "iris",
				git_rename = "pine",
				git_stage = "iris",
				git_text = "rose",
				git_untracked = "subtle",

				h1 = "iris",
				h2 = "foam",
				h3 = "rose",
				h4 = "gold",
				h5 = "pine",
				h6 = "foam",
			},
		})
		vim.cmd.colorscheme("rose-pine")

		-- vim.api.nvim_set_hl(0, "TreesitterContextBottom", {
		-- 	underline = true,
		-- 	sp = "#c4a7e7", -- your desired underline color
		-- 	fg = "NONE",
		-- 	bg = "NONE",
		-- })
		-- vim.schedule(function()
		-- 	vim.api.nvim_set_hl(0, "DapStoppedLine", {
		-- 		bg = "#3c3836",
		-- 		underline = true,
		-- 	})
		-- end)
	end,
}

-- return {
-- 	gh = "sainnhe/everforest",
-- 	alias = "everforest",
-- 	config = function()
-- 		vim.cmd.colorscheme("everforest")
-- 	end,
-- }

-- return {
-- 	gh = "metalelf0/jellybeans-nvim",
-- 	config = function()
-- 		vim.cmd.colorscheme("jellybeans-nvim")
-- 	end,
-- }

-- return {
-- 	gh = "vague-theme/vague.nvim",
-- 	config = function()
-- 		require("vague").setup({
-- 			transparent = true, -- If true, background is not set
-- 			bold = true, -- Disable bold globally
-- 			italic = true, -- Disable italic globally
-- 			-- on_highlights = function(hl, colors) end,
-- 			-- colors = {
-- 			-- 	bg = "#141415",
-- 			-- 	inactiveBg = "#1c1c24",
-- 			-- 	fg = "#cdcdcd",
-- 			-- 	floatBorder = "#878787",
-- 			-- 	line = "#252530",
-- 			-- 	comment = "#606079",
-- 			-- 	builtin = "#b4d4cf",
-- 			-- 	func = "#c48282",
-- 			-- 	string = "#e8b589",
-- 			-- 	number = "#e0a363",
-- 			-- 	property = "#c3c3d5",
-- 			-- 	constant = "#aeaed1",
-- 			-- 	parameter = "#bb9dbd",
-- 			-- 	visual = "#333738",
-- 			-- 	error = "#d8647e",
-- 			-- 	warning = "#f3be7c",
-- 			-- 	hint = "#7e98e8",
-- 			-- 	operator = "#90a0b5",
-- 			-- 	keyword = "#6e94b2",
-- 			-- 	type = "#9bb4bc",
-- 			-- 	search = "#405065",
-- 			-- 	plus = "#7fa563",
-- 			-- 	delta = "#f3be7c",
-- 			-- },
-- 		})
-- 		vim.cmd.colorscheme("vague")
-- 	end,
-- }
