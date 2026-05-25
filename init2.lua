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
-- do
-- 	vim.diagnostic.config({
-- 		update_in_insert = false,
-- 		severity_sort = true,
-- 		float = { border = "rounded", source = "if_many" },
-- 		underline = { severity = { min = vim.diagnostic.severity.WARN } },
--
-- 		-- Can switch between these as you prefer
-- 		virtual_text = true, -- Text shows up at the end of the line
-- 		virtual_lines = false, -- Text shows up underneath the line, with virtual lines
--
-- 		-- Auto open the float, so you can easily read the errors when jumping with `[d` and `]d`
-- 		jump = {
-- 			on_jump = function(_, bufnr)
-- 				vim.diagnostic.open_float({
-- 					bufnr = bufnr,
-- 					scope = "cursor",
-- 					focus = false,
-- 				})
-- 			end,
-- 		},
-- 	})
-- end

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
		man.add_plugin({ gh = "nvim-tree/nvim-web-devicons" })

		man.add_plugin({ file = "modules.gitsigns" })
		man.add_plugin({ file = "modules.whichkey" })

		man.add_plugin({ gh = "folke/todo-comments.nvim" })
		man.add_plugin({ gh = "nvim-lua/plenary.nvim" })
		man.add_plugin({ file = "modules.harpoon" })

		man.add_plugin({ file = "modules.mini" })

		man.add_plugin({ gh = "nvim-telescope/telescope-fzf-native.nvim" })
		man.add_plugin({ gh = "nvim-telescope/telescope-ui-select.nvim" })
		man.add_plugin({ file = "modules.telescope" })

		man.add_plugin({ file = "modules.theme" })

		man.add_plugin({ gh = "j-hui/fidget.nvim" })

		man.add_plugin({ gh = "folke/lazydev.nvim" })

		man.add_plugin({ gh = "williamboman/mason.nvim", config = {} })
		man.add_plugin({ gh = "williamboman/mason-lspconfig.nvim" })
		man.add_plugin({ gh = "WhoIsSethDaniel/mason-tool-installer.nvim", config = {} })

		man.add_plugin({ file = "modules.lsp" })

		man.add_plugin({ file = "modules.blinkcmp" })

		man.apply()
	end
end
