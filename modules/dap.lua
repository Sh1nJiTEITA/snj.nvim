-- =====================================================================
-- STATE & HELPERS
-- =====================================================================
local cached_binary = nil
local cached_args = nil

local function pick_binary(cb)
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	require("telescope.builtin").find_files({
		prompt_title = "Select Executable",
		find_command = { "fd", "--hidden", "--no-ignore", "--type", "x" },
		previewer = false,
		attach_mappings = function(prompt_bufnr, _)
			actions.select_default:replace(function()
				local selection = action_state.get_selected_entry()
				actions.close(prompt_bufnr)
				cached_binary = selection[1]
				cb(cached_binary)
			end)
			return true
		end,
	})
end

local function map(mode, lhs, rhs, desc)
	vim.keymap.set(mode, lhs, rhs, { desc = desc, silent = true })
end

-- =====================================================================
-- TEMPORARY GDB KEYMAPS
-- =====================================================================
local function enable_gdb_keys(dap)
	map("n", "n", dap.step_over, "Debug: Next (Step Over)")
	map("n", "s", dap.step_into, "Debug: Step (Step Into)")
	map("n", "f", dap.step_out, "Debug: Finish (Step Out)")
	map("n", "c", dap.continue, "Debug: Continue")
	map("n", "u", dap.up, "Debug: Up Stack")
	map("n", "d", dap.down, "Debug: Down Stack")
end

local function disable_gdb_keys()
	pcall(vim.keymap.del, "n", "n")
	pcall(vim.keymap.del, "n", "s")
	pcall(vim.keymap.del, "n", "f")
	pcall(vim.keymap.del, "n", "c")
	pcall(vim.keymap.del, "n", "u")
	pcall(vim.keymap.del, "n", "d")
end

-- =====================================================================
-- SETUP FUNCTIONS
-- =====================================================================
local function setup_ui(dapui)
	dapui.setup({
		wrap = true,
		floating = {
			max_width = 80,
			max_height = 20,
			border = "rounded",
			mappings = {
				close = { "q", "<Esc>" },
			},
		},
		layouts = {
			{
				position = "left",
				size = 50,
				elements = {
					{ id = "breakpoints", size = 0.1 },
					{ id = "scopes", size = 0.3 },
					{ id = "watches", size = 0.6 },
				},
			},
			{
				position = "bottom",
				size = 15,
				elements = {
					{ id = "repl", size = 0.5 },
					{ id = "console", size = 0.5 },
				},
			},
		},
	})
end

local function setup_listeners(dap, dapui)
	dap.listeners.after.event_initialized["dapui_config"] = function()
		dapui.open()
		enable_gdb_keys(dap)
	end
	dap.listeners.before.event_terminated["dapui_config"] = function()
		disable_gdb_keys()
	end
	dap.listeners.before.event_exited["dapui_config"] = function()
		disable_gdb_keys()
	end
end

local function setup_adapters(dap)
	dap.adapters.gdb = {
		type = "executable",
		command = "gdb",
		args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
	}
end

local function setup_configurations(dap)
	dap.configurations.cpp = {
		{
			name = "Launch",
			type = "gdb",
			request = "launch",
			program = function()
				return coroutine.create(function(coro)
					if cached_binary then
						coroutine.resume(coro, cached_binary)
					else
						pick_binary(function(path)
							coroutine.resume(coro, path)
						end)
					end
				end)
			end,
			args = function()
				if cached_args then
					return cached_args
				end

				local args_string = vim.fn.input("Arguments: ")
				if args_string == "" then
					cached_args = {}
				else
					cached_args = vim.split(args_string, "%s+")
				end
				return cached_args
			end,
			cwd = "${workspaceFolder}",
			stopAtBeginningOfMainSubprogram = true,
		},
	}
end

local function setup_global_keymaps(dap, dapui)
	-- Standard Execution Control
	map("n", "<leader>dc", dap.continue, "Debug: Continue/Start")
	map("n", "<leader>dt", function()
		dap.terminate()
		dapui.close()
	end, "Debug: Terminate")

	-- Breakpoints
	map("n", "<leader>db", dap.toggle_breakpoint, "Debug: Toggle Breakpoint")
	map("n", "<leader>dB", function()
		dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
	end, "Debug: Conditional Breakpoint")

	-- Stepping
	map("n", "<leader>di", dap.step_into, "Debug: Step Into")
	map("n", "<leader>do", dap.step_over, "Debug: Step Over")
	map("n", "<leader>dO", dap.step_out, "Debug: Step Out")

	-- UI & Evaluation
	map("n", "<leader>dh", dapui.eval, "Debug: Hover (Eval)")
	map("n", "<leader>dE", dap.repl.open, "Debug: Open REPL")
	map("n", "<leader>du", dapui.toggle, "Debug: Toggle UI")
	map("n", "<leader>ds", function()
		local widgets = require("dap.ui.widgets")
		widgets.centered_float(widgets.scopes, { border = "rounded" })
	end, "Debug: Scopes")

	-- Restarts & Cache Management
	map("n", "<leader>dr", dap.run_last, "Debug: Restart / Run Last")
	map("n", "<leader>dR", function()
		dap.terminate()
		vim.defer_fn(function()
			dap.continue()
		end, 200)
	end, "Debug: Hard Restart")

	map("n", "<leader>dx", function()
		cached_binary = nil
		cached_args = nil
		print("Debug cache cleared! Next run will prompt for binary and args.")
	end, "Debug: Reset Binary and Args Cache")

	map("n", "<leader>da", function()
		local current_args_str = (cached_args and #cached_args > 0) and table.concat(cached_args, " ") or ""
		local status, new_args_str = pcall(vim.fn.input, {
			prompt = "Modify Arguments: ",
			default = current_args_str,
			cancelreturn = "__CANCEL__",
		})
		if status and new_args_str ~= "__CANCEL__" then
			if new_args_str == "" then
				cached_args = {}
				print("Args cleared.")
			else
				cached_args = vim.split(new_args_str, "%s+", { trimempty = true })
				print("Args updated: " .. new_args_str)
			end
		else
			print("Modification cancelled. Args unchanged.")
		end
	end, "Debug: Modify Current Args")

	map("n", "<leader>dw", function()
		local session = dap.session()
		if not session then
			vim.notify("You must start a debug session first to set a watchpoint.", vim.log.levels.WARN)
			return
		end

		local cur_word = vim.fn.expand("<cword>")
		local expr = vim.fn.input("Watch (write) Expression: ", cur_word)

		if expr ~= "" then
			session:request("evaluate", {
				expression = "watch " .. expr,
				context = "repl",
			}, function(err, _)
				vim.schedule(function()
					if err then
						vim.notify("GDB error setting watchpoint for: " .. expr, vim.log.levels.ERROR)
					else
						vim.notify("GDB applied watchpoint: " .. expr, vim.log.levels.INFO)
					end
				end)
			end)
		end
	end, "Debug: Watch Variable (Data Breakpoint)")
end

-- =====================================================================
-- PLUGIN MANAGER EXPORT
-- =====================================================================
return {
	gh = "mfussenegger/nvim-dap",
	alias = "dap",
	-- Inline definitions utilizing your new `plman` recursive dependencies feature
	deps = {
		{ gh = "rcarriga/nvim-dap-ui", alias = "dapui", config = false },
		{ gh = "nvim-neotest/nvim-nio", alias = "nio", config = false },
	},
	config = function()
		local dap = require("dap")
		local dapui = require("dapui")

		setup_ui(dapui)
		setup_adapters(dap)
		setup_configurations(dap)
		setup_listeners(dap, dapui)
		setup_global_keymaps(dap, dapui)
	end,
}
