-- For each buildin neovim setting can be opened help-window with description
-- like at https://neovim.io/doc/ with using single command:
--
-- :help '<any setting>'
--

do
	vim.loader.enable()

	-- Setting leader key, which is used for key-bindings
	vim.g.mapleader = " "

	-- Same as previous
	vim.g.maplocalleader = " "

	-- Signalling that we use nerd font
	vim.g.have_nerd_font = true

	-- Enabling numbers on the left
	vim.o.number = true

	-- Using relative numbers for faster jumps
	vim.o.relativenumber = true

	-- Sometimes it is comfortable to use mouse with reading code
	-- So, binding it to "n" or normal mode
	vim.o.mouse = "n"

	-- Disabling show modes in bottom panel like "-- Insert Mode --" or whatever
	vim.o.showmode = false

	-- Using this mode provides sharing copy-buffer with system and not using
	-- inner neovim one, so if you yank code inside editor text can be used
	-- in other programs
	vim.o.clipboard = "unnamedplus"

	-- Visual advancement if line is too long and is beeing wrapped indentation
	-- is stopped, so we see that line should be refactored
	vim.o.breakindent = true

	-- Saving undo-tree to file, so as program restarts undo-tree with changes
	-- is beeing loaded and can be used farther
	vim.o.undofile = true

	-- Ignore case with searching and other stuff
	vim.o.ignorecase = true

	-- If you press upper-case letters in search or other same stuff,
	-- vim.o.ignorecase will be ignored
	vim.o.smartcase = true

	-- How signcolumn (like git '+'-insertions) will be shown
	vim.o.signcolumn = "number"

	-- Just dont touch this 2
	vim.o.updatetime = 250
	vim.o.timeoutlen = 300

	-- If splitting screen, new panel will be showned on the right of current
	vim.o.splitright = true

	-- Same as previous but for horizontal splits
	vim.o.splitbelow = true

	-- Disable showing trailing spaces / tabs and other unneeded parts of code
	-- So formaters/linters will do there work
	vim.o.list = false

	-- Cool settings, shows selection insied text and in special bottom window
	-- so you can check, if any other rows in whole file will be processed
	vim.o.inccommand = "split"

	-- I dont prefer using special background color change for showing where
	-- my cursor is, so it is disabled
	vim.o.cursorline = false

	-- Handy setting which sets a range in what our cursor can be located by
	-- erasing vim.o.scrolloff lines from begin & end of file, so if cursor
	-- is moved farther then this range whole buffer view will be moved
	vim.o.scrolloff = 10

	-- Smt about searching, this setting always were here
	vim.o.hlsearch = true

	-- Keeping directory current, with buildin 'Explore' window after second
	-- open
	vim.g.netrw_keepdir = 0

	-- Dont show help banner inside buildin explorer
	vim.g.netrw_banner = 0

	-- Enabling 24-bit RGB colors
	vim.o.termguicolors = true

	-- Cool setting to show/hide some part of code
	--
	-- From https://neovim.io/doc/user/options/#'conceallevel'
	--
	-- 0	Text is shown normally
	--
	-- 1	Each block of concealed text is replaced with one
	-- 		character.  If the syntax item does not have a custom
	-- 		replacement character defined (see :syn-cchar) the
	-- 		character defined in 'listchars' is used.
	-- 		It is highlighted with the "Conceal" highlight group.
	--
	-- 2	Concealed text is completely hidden unless it has a
	-- 		custom replacement character defined (see
	-- 		:syn-cchar).
	--
	-- 3	Concealed text is completely hidden.
	vim.o.conceallevel = 1

	-- Change tabs to spaces
	vim.o.expandtab = true

	-- How many spaces tab costs :)
	vim.o.tabstop = 4

	-- How many spaces to use with autoindent
	-- (0 - same as inside vim.o.tabstop)
	vim.o.shiftwidth = 0

	-- Let spaces behave like tabs
	vim.o.softtabstop = 4

	vim.o.colorcolumn = "80"

	vim.o.packpath = vim.o.packpath
end

-------------------------------------------------------------------------------
-- Diagnostic
-------------------------------------------------------------------------------
do
	vim.diagnostic.config({
		update_in_insert = false,
		severity_sort = true,
		float = { border = "rounded", source = "if_many" },
		underline = { severity = { min = vim.diagnostic.severity.WARN } },

		-- Can switch between these as you prefer
		virtual_text = true, -- Text shows up at the end of the line
		virtual_lines = false, -- Text shows up underneath the line, with virtual lines

		-- Auto open the float, so you can easily read the errors when jumping with `[d` and `]d`
		jump = {
			on_jump = function(_, bufnr)
				vim.diagnostic.open_float({
					bufnr = bufnr,
					scope = "cursor",
					focus = false,
				})
			end,
		},
	})
end

-------------------------------------------------------------------------------
-- Basic mappings
-------------------------------------------------------------------------------
do
	vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

	vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, {
		desc = "Show diagnostic [E]rror messages",
	})

	vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, {
		desc = "Open diagnostic [Q]uickfix list",
	})

	vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

	vim.keymap.set("n", "<Up>", ":resize -2<CR>")
	vim.keymap.set("n", "<Down>", ":resize +2<CR>")
	vim.keymap.set("n", "<Left>", ":vertical resize -2<CR>")
	vim.keymap.set("n", "<Right>", ":vertical resize +2<CR>")

	vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
	vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
	vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
	vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

	vim.api.nvim_create_user_command("Wqa", "wqa", {})
	vim.api.nvim_create_user_command("WQa", "wqa", {})
	vim.api.nvim_create_user_command("WQA", "wqa", {})

	vim.api.nvim_create_user_command("Wa", "wa", {})
	vim.api.nvim_create_user_command("WA", "wa", {})
	-- vim.api.nvim_create_user_command("wA", "wa", {})
end

do
	vim.api.nvim_create_autocmd("TextYankPost", {
		desc = "Highlight when yanking (copying) text",
		group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
		callback = function()
			vim.hl.on_yank()
		end,
	})
end

do
	local function run_build(name, cmd, cwd)
		local result = vim.system(cmd, { cwd = cwd }):wait()
		if result.code ~= 0 then
			local stderr = result.stderr or ""
			local stdout = result.stdout or ""
			local output = stderr ~= "" and stderr or stdout
			if output == "" then
				output = "No output from build command."
			end
			vim.notify(("Build failed for %s:\n%s"):format(name, output), vim.log.levels.ERROR)
		end
	end

	vim.api.nvim_create_autocmd("PackChanged", {
		callback = function(ev)
			local name = ev.data.spec.name
			local kind = ev.data.kind
			if kind ~= "install" and kind ~= "update" then
				return
			end

			if name == "telescope-fzf-native.nvim" and vim.fn.executable("make") == 1 then
				run_build(name, { "make" }, ev.data.path)
				return
			end

			if name == "LuaSnip" then
				if vim.fn.has("win32") ~= 1 and vim.fn.executable("make") == 1 then
					run_build(name, { "make", "install_jsregexp" }, ev.data.path)
				end
				return
			end

			if name == "nvim-treesitter" then
				if not ev.data.active then
					vim.cmd.packadd("nvim-treesitter")
				end
				vim.cmd("TSUpdate")
				return
			end
		end,
	})

	do
		local man = require("plman")

		man.add_plugin({ gh = "NMAC427/guess-indent.nvim" })
		man.add_plugin({
			gh = "folke/tokyonight.nvim",
			alias = "tokyonight",
			config = function()
				require("tokyonight").setup({})
				vim.cmd.colorscheme("tokyonight-night")
			end,
		})

		man.add_plugin({ gh = "nvim-tree/nvim-web-devicons" })

		man.add_plugin({
			gh = "lewis6991/gitsigns.nvim",
			config = function()
				local module = require("gitsigns")

				module.setup({
					signs = {
						add = { text = "+" },
						change = { text = "~" },
						delete = { text = "_" },
						topdelete = { text = "‾" },
						changedelete = { text = "~" },
					},
					word_diff = false,
				})

				local toggleSigns = function()
					local vim_status = vim.opt.signcolumn:get()
					if vim_status == "yes" then
						vim.opt.signcolumn = "no"
						module.toggle_signs(false)
					else
						vim.opt.signcolumn = "yes"
						module.toggle_signs(true)
					end
				end

				vim.keymap.set("n", "<leader>ts", toggleSigns, { desc = "[T]oggle git [S]ings" })

				-- show preview inside code of changed from last commit code
				vim.keymap.set("n", "<leader>pq", module.preview_hunk_inline, { desc = "[P]review hunk" })

				-- show panel on the left with history of git changes
				vim.keymap.set("n", "<leader>pB", module.blame, { desc = "[P]review [B]lame panel" })
				vim.keymap.set("n", "<leader>pb", module.blame_line, { desc = "[P]review [B]lame line" })
				vim.keymap.set("n", "<leader>pd", module.toggle_word_diff, { desc = "[P]review [D]iff inline" })
				vim.keymap.set("n", "<leader>pD", module.diffthis, { desc = "[P]review [D]iff" })
			end,
		})
		--
		man.add_plugin({
			gh = "folke/which-key.nvim",
			config = {
				delay = 500,
				icons = {
					mappings = vim.g.have_nerd_font,
					keys = vim.g.have_nerd_font and {} or {
						Up = "<Up> ",
						Down = "<Down> ",
						Left = "<Left> ",
						Right = "<Right> ",
						C = "<C-…> ",
						M = "<M-…> ",
						D = "<D-…> ",
						S = "<S-…> ",
						CR = "<CR> ",
						Esc = "<Esc> ",
						ScrollWheelDown = "<ScrollWheelDown> ",
						ScrollWheelUp = "<ScrollWheelUp> ",
						NL = "<NL> ",
						BS = "<BS> ",
						Space = "<Space> ",
						Tab = "<Tab> ",
						F1 = "<F1>",
						F2 = "<F2>",
						F3 = "<F3>",
						F4 = "<F4>",
						F5 = "<F5>",
						F6 = "<F6>",
						F7 = "<F7>",
						F8 = "<F8>",
						F9 = "<F9>",
						F10 = "<F10>",
						F11 = "<F11>",
						F12 = "<F12>",
					},
				},

				spec = {
					{ "<leader>s", group = "[S]earch" },
					{ "<leader>t", group = "[T]oggle" },
					{ "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
				},

				win = {
					no_overlap = true,
					padding = { 0, 0 },
					title = true,
					title_pos = "center",
					zindex = 1000,
					border = "rounded",
					bo = {},
					wo = {},
				},
			},
		})

		man.add_plugin({ gh = "folke/todo-comments.nvim", config = { signs = false } })

		man.add_plugin({ gh = "nvim-lua/plenary.nvim" })

		man.add_plugin({
			gh = "ThePrimeagen/harpoon",
			branch = "harpoon2",
			config = function()
				local function switch_current_header_source()
					local buf = vim.api.nvim_get_current_buf()

					-- Clangd
					local resp = vim.lsp.buf_request_sync(buf, "textDocument/switchSourceHeader", {
						uri = vim.uri_from_bufnr(buf),
					}, 50)

					if resp == nil then
						return
					end

					for _, data in pairs(resp) do
						if data.result then
							buf = vim.uri_to_bufnr(data.result) or vim.api.nvim_get_current_buf()
							vim.api.nvim_set_current_buf(buf)
						end
					end
				end

				local harpoon = require("harpoon")

				vim.keymap.set("n", "<leader>aa", function()
					harpoon:list():add()
				end, { desc = "Add to Harpoon" })

				vim.keymap.set("n", "<leader>ad", function()
					harpoon:list():remove()
				end, {
					desc = "Delete from Harpoon",
				})

				vim.keymap.set("n", "<leader>g", function()
					harpoon.ui:toggle_quick_menu(harpoon:list())
				end, {
					desc = "Toggle Harpoon quick menu",
				})

				-- More smart switching logic for c/cpp files
				local switch = function(item_idx)
					-- If C++ or C -> Adding header <-> src files switch
					-- So less amount of files need to be stored inside harpoon list. Only
					-- headers can be stored
					if vim.bo.filetype == "c" or vim.bo.filetype == "cpp" then
						if item_idx > #harpoon:list().items then
							return
						end

						local project_dir = harpoon:list().config:get_root_dir()
						local after_path = harpoon:list():get(item_idx).value
						local full_path = vim.fn.fnamemodify(project_dir .. "/" .. after_path, ":p")
						local buf = vim.uri_to_bufnr(vim.uri_from_fname(full_path))
						local current_buf = vim.api.nvim_get_current_buf()
						-- If requesting buffer are the same as current:
						-- 1. Go to <*.h> (header) file if <*.cpp> (src) file selected
						-- 2. Viceversa
						if buf == current_buf then
							switch_current_header_source()
						else
							harpoon:list():select(item_idx)
						end
					else
						harpoon:list():select(item_idx)
					end
				end

				-- Adding select mappings
				for i = 1, 6 do
					local desc = "Select Harpoon buf " .. i
					vim.keymap.set("n", "<leader>" .. i, function()
						switch(i)
					end, { desc = desc })
				end

				-- Adding special auto header-src switch for any bound/nonbound to harpoon
				-- buf
				-- Works only for buffers attached to c/cpp filetypes
				vim.api.nvim_create_autocmd("FileType", {
					pattern = { "c", "cpp" },
					callback = function()
						local opts = { noremap = true, silent = true, buffer = true }
						vim.keymap.set("n", "<leader>0", function()
							switch_current_header_source()
						end, opts)
					end,
				})

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
			end,
		})

		man.apply()
	end
end
