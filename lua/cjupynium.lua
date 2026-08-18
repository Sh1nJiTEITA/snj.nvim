local function get_git_root()
	local git_root = vim.fn.system("git rev-parse --show-toplevel")

	if vim.v.shell_error == 0 then
		return vim.trim(git_root)
	end

	return vim.fn.getcwd()
end

return {
	gh = "kiyoon/jupynium.nvim",
	config = function()
		require("jupynium").setup({
			auto_download_ipynb = true,
			notebook_dir = nil,
			-- notebook_dir = get_git_root(),
		})

		vim.keymap.set("n", "<leader>jr", function()
			vim.cmd("JupyniumStartAndAttachToServer")
		end, { desc = "[j]upynium sta[r]t" })

		vim.keymap.set("n", "<leader>jsy", function()
			vim.cmd("JupyniumStartSync")
		end, { desc = "[j]upynium [s][y]nc" })

		vim.keymap.set("n", "<leader>jss", function()
			vim.cmd("JupyniumStopSync")
		end, { desc = "[j]upynium [s]top [s]ync" })

		vim.keymap.set("n", "<leader>jkr", function()
			vim.cmd("JupyniumKernelRestart")
		end, { desc = "[j]upynium [k]ernel [r]estart" })
	end,
}
