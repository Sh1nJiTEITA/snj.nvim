-- return {
-- 	gh = "nvim-neo-tree/neo-tree.nvim",
-- 	deps = {
-- 		{ gh = "nvim-lua/plenary.nvim" },
-- 		{ gh = "MunifTanjim/nui.nvim" },
-- 		{ gh = "nvim-tree/nvim-web-devicons" },
-- 	},
--
-- 	config = function()
-- 		local mod = require("neo-tree")
--
-- 		vim.keymap.set("n", "<C-t>", function()
-- 			vim.cmd("Neotree toggle")
-- 		end, { desc = "[T]oggle neotree" })
--
-- 		mod.setup({})
-- 	end,
-- }

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

		-- open the file, then start gitsigns diff once it has attached
		local function open_and_diff(state)
			local node = state.tree:get_node()
			require("neo-tree.sources.common.commands").open(state)
			if node.type ~= "file" then
				return
			end

			local buf = vim.api.nvim_get_current_buf()
			local tries = 0
			local function try()
				if vim.b[buf].gitsigns_status_dict then
					require("gitsigns").diffthis()
				elseif tries < 20 then
					tries = tries + 1
					vim.defer_fn(try, 25)
				end
			end
			vim.schedule(try)
		end

		mod.setup({
			git_status = {
				window = {
					mappings = {
						["<cr>"] = "open_and_diff",
						["o"] = "open_and_diff",
						["D"] = "open", -- plain open, no diff
					},
				},
				commands = {
					open_and_diff = open_and_diff,
				},
			},
		})
	end,
}
