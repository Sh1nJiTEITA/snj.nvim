-- Loads lazy vim ... ---------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)
-- Loads lazy vim ... ---------------------------------------------------------

local function ToggleTheme()
	local current_theme = vim.o.background

	if current_theme == "dark" then
		require("gruvbox").setup({
			transparent_mode = false,
		})
		vim.o.background = "light"
	end
	if current_theme == "light" then
		require("gruvbox").setup({
			transparent_mode = true,
		})
		vim.o.background = "dark"
	end

	-- vim.o.background = "light"
end

vim.api.nvim_create_user_command("ToggleTheme", function()
	ToggleTheme()
end, { nargs = 0 })

local function ConvertDoxygenToCppStyle(start_line, end_line)
	local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
	local new_lines = {}

	for _, line in ipairs(lines) do
		local trimmed = vim.trim(line)

		if trimmed == "/**" or trimmed == "*/" then
			goto continue
		end

		trimmed = trimmed:gsub("^%s*%*%s?", "")

		table.insert(new_lines, "//! " .. trimmed)

		::continue::
	end

	vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, new_lines)
end

vim.api.nvim_create_user_command("ConvertComment", function(opts)
	ConvertDoxygenToCppStyle(opts.line1, opts.line2)
end, { nargs = 0, range = true })

function AddTaskNumbers(base)
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	local counters = {}
	local result = {}

	-- parse the base prefix into numbers (e.g. "1.6" → {1, 6})
	local baseParts = {}
	if base then
		for part in tostring(base):gmatch("%d+") do
			table.insert(baseParts, tonumber(part))
		end
	end

	for _, line in ipairs(lines) do
		local level = select(2, line:gsub("\t", "")) -- count tabs

		-- ensure all deeper levels exist
		for i = 1, level + 1 do
			if counters[i] == nil then
				counters[i] = 0
			end
		end

		counters[level + 1] = counters[level + 1] + 1
		for i = level + 2, #counters do
			counters[i] = nil
		end

		-- join base + current counters up to depth
		local parts = vim.deepcopy(baseParts)
		for i = 1, level + 1 do
			table.insert(parts, counters[i])
		end
		local num = table.concat(parts, ".")

		-- insert number
		local new_line = line:gsub("(- %[ %] )", "%1" .. num .. " ")
		table.insert(result, new_line)
	end

	vim.api.nvim_buf_set_lines(0, 0, -1, false, result)
end

vim.api.nvim_create_user_command("AddTaskNums", function(opts)
	AddTaskNumbers(opts.args ~= "" and opts.args or nil)
end, { nargs = "?" })

vim.api.nvim_create_user_command("Impl", function(opts)
	local bufnr = vim.api.nvim_get_current_buf()
	local start_line = opts.line1
	local end_line = opts.line2

	local lines = vim.api.nvim_buf_get_lines(bufnr, start_line - 1, end_line, false)

	print(vim.inspect(lines))
end, {
	range = true,
	nargs = "*",
})

vim.api.nvim_create_user_command("Impl2", function(opts)
	local arg = opts.fargs[1] or "ref"
	require("cpp").main.run(arg)
end, {
	nargs = "?",
})

vim.api.nvim_create_user_command("Resolve", function(opts)
	local arg = opts.fargs[1] or "ref"
	require("cpp").main.resolveTest(arg)
end, { nargs = "?" })

vim.api.nvim_create_user_command("Neig", function()
	require("cpp").main.print_neighbors_under_cursor()
end, {})

vim.api.nvim_create_user_command("Decl", function()
	local cpp = require("cpp").main
	cpp.get_neighbors_under_cursor(function(neigh)
		for _, sym in pairs(neigh) do
			cpp.find_symbol_impl(sym)
			return
		end
	end)
end, {})

vim.api.nvim_create_user_command("NeigWin", function()
	local cpp = require("cpp").main
	cpp.show_all_neighbors_under_cursor()
end, {})

-- vim.keymap.set("n", "<leader>8", function()
-- 	-- require("cpp").main.goto_definition_or_create_under_cursor()
-- 	--
-- 	local c = vim.api.nvim_win_get_cursor(0)
-- 	local buf = vim.api.nvim_get_current_buf()
-- 	require("cpp").lsp.apply_to_scope_items(buf, c[1] - 1, c[2], function(parent, symbol)
-- 		print(vim.inspect(parent))
-- 	end)
-- end, { desc = "Move focus to the upper window" })

-- vim.keymap.set("n", "<leader>7", function()
-- 	-- require("cpp").main.show_all_neighbors_under_cursor()
-- 	require("cpp").main.create_scope_window()
-- end, { desc = "Move focus to the upper window" })

local function iso_timestamp()
	local t = os.time()
	local utc = os.time(os.date("!*t", t))
	local diff = os.difftime(t, utc)

	local sign = diff >= 0 and "+" or "-"
	diff = math.abs(diff)
	local hours = math.floor(diff / 3600)
	local minutes = math.floor((diff % 3600) / 60)

	return os.date("%Y-%m-%dT%H:%M:%S", t) .. string.format("%s%02d:%02d", sign, hours, minutes)
end

vim.api.nvim_create_user_command("Timestamp", function(opts)
	local ts = iso_timestamp()
	vim.api.nvim_put({ ts }, "c", true, true)
end, {
	-- nargs = "?",
})

CurrentRosePineVariant = "dark"

---@param mode "light" | "dark"
local function setupTheme(mode)
	local transp = nil
	local theme_name = nil
	if mode == "light" then
		transp = false
		theme_name = "rose-pine-dawn"
	else
		transp = true
		theme_name = "rose-pine-main"
	end

	require("rose-pine").setup({
		variant = "auto", -- auto, main, moon, or dawn dark_variant = "main", -- main, moon, or dawn
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
			transparency = transp,
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
	vim.cmd("colorscheme " .. theme_name)
	vim.api.nvim_set_hl(0, "TreesitterContextBottom", {
		underline = true,
		sp = "#c4a7e7",
		fg = "NONE",
		bg = "NONE",
	})
	initYankOnHighlight()
	vim.schedule(function()
		vim.api.nvim_set_hl(0, "DapStoppedLine", {
			bg = "#3c3836",
			underline = true,
		})
	end)
end

vim.api.nvim_create_user_command("SwitchTheme", function(opts)
	if CurrentRosePineVariant == "dark" then
		setupTheme("light")
		CurrentRosePineVariant = "light"
	else
		setupTheme("dark")
		CurrentRosePineVariant = "dark"
	end
end, { nargs = 0 })

return
