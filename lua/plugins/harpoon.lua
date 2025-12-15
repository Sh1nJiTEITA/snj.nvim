IsHarpoonMenuOpen = false

-- local conf = require("telescope.config").values
-- local function toggle_telescope(harpoon_files)
--    local file_paths = {}
--    for _, item in ipairs(harpoon_files.items) do
--       table.insert(file_paths, item.value)
--    end
--
--    require("telescope.pickers")
--       .new({}, {
--          prompt_title = "Harpoon",
--          finder = require("telescope.finders").new_table({
--             results = file_paths,
--          }),
--          previewer = conf.file_previewer({}),
--          sorter = conf.generic_sorter({}),
--       })
--       :find()
-- end

return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope.nvim",
	},

	event = "VimEnter",
	config = function()
		local harpoon = require("harpoon")
		local cpp = require("cpp").main

		vim.keymap.set("n", "<leader>aa", function()
			harpoon:list():add()
		end, {
			desc = "Add to harpoon2",
		})

		vim.keymap.set("n", "<leader>ad", function()
			harpoon:list():remove()
		end, {
			desc = "Delete from Harpoon2",
		})

		vim.keymap.set("n", "<leader>g", function()
			harpoon.ui:toggle_quick_menu(harpoon:list())
		end, {
			desc = "Toggle harpoon2 quick menu",
		})

		local cpp_switch = function(item_idx)
			local list = harpoon:list()
			if item_idx < 1 or item_idx > #list.items then
				return
			end
			local project_dir = list.config:get_root_dir()
			local after_path = list:get(item_idx).value
			local full_path = project_dir .. "/" .. after_path
			full_path = full_path:gsub("//+", "/") -- normalize double slashes
			local buf = vim.uri_to_bufnr(vim.uri_from_fname(full_path))
			local current_buf = vim.api.nvim_get_current_buf()
			if buf == current_buf then
				cpp.switchHeaderSourceForCurrentBufferSync()
			else
				list:select(item_idx)
			end
		end

		local switch = function(item_idx)
			-- if C++ or C
			if vim.bo.filetype == "c" or vim.bo.filetype == "cpp" then
				cpp_switch(item_idx)
			else
				harpoon:list():select(item_idx)
			end
		end

		-- No capture by harpoon but switch
		vim.keymap.set("n", "<leader>0", function()
			cpp.switchHeaderSourceForCurrentBufferSync()
		end)

		for i = 1, 6 do
			vim.keymap.set("n", "<leader>" .. i, function()
				switch(i)
			end, { desc = "Toggle harpoon page " .. i })
		end

		-- Toggle previous & next buffers stored within Harpoon list
		vim.keymap.set("n", "<A-TAB>", function()
			harpoon:list():next()
		end, {
			desc = "Go next buffer via harpoon2",
		})
		vim.keymap.set("n", "<A-S-TAB>", function()
			harpoon:list():prev()
		end, {
			desc = "Go prev buffer via harpoon2",
		})

		local conf = require("telescope.config").values
		local function toggle_telescope(harpoon_files)
			local file_paths = {}
			for _, item in ipairs(harpoon_files.items) do
				table.insert(file_paths, item.value)
			end

			require("telescope.pickers")
				.new({}, {
					prompt_title = "Harpoon",
					finder = require("telescope.finders").new_table({
						results = file_paths,
					}),
					previewer = conf.file_previewer({}),
					sorter = conf.generic_sorter({}),
				})
				:find()
		end

		-- vim.keymap.set("n", "<C-e>", function()
		-- 	toggle_telescope(harpoon:list())
		-- end, { desc = "Open harpoon window" })
	end,
}
