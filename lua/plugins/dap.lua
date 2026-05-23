local cached_binary = nil

local function pick_binary(cb)
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	require("telescope.builtin").find_files({
		prompt_title = "Select Executable",
		find_command = { "fd", "--hidden", "--no-ignore", "--type", "x" },
		previewer = false,
		attach_mappings = function(prompt_bufnr, map)
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

return {
	"mfussenegger/nvim-dap",
	dependencies = {
		"rcarriga/nvim-dap-ui",
		"nvim-neotest/nvim-nio",
	},
	config = function()
		local dap = require("dap")
		local dapui = require("dapui")
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
					-- LEFT PANEL
					position = "left",
					size = 50, -- Width of the left panel
					elements = {
						-- Locals (Scopes) upper, then Watches
						{ id = "breakpoints", size = 0.1 }, -- Breakpoints tucked underneath (25% height)
						{ id = "scopes", size = 0.3 }, -- Takes up 60% of left panel height
						{ id = "watches", size = 0.6 }, -- Takes up 40% of left panel height
					},
				},
				{
					-- RIGHT PANEL
					position = "bottom",
					size = 15, -- Made a bit wider so your GDB prompt is comfortable to read
					elements = {
						-- GDB Prompt (REPL) and Breakpoints
						{ id = "repl", size = 0.5 }, -- REPL made much bigger (75% height)
						{ id = "console", size = 0.5 },
					},
				},
			},
		})

		local map = function(mode, lhs, rhs, desc)
			vim.keymap.set(mode, lhs, rhs, { desc = desc, silent = true })
		end

		local function enable_gdb_keys()
			map("n", "n", dap.step_over, "Debug: Next (Step Over)")
			map("n", "s", dap.step_into, "Debug: Step (Step Into)")
			map("n", "f", dap.step_out, "Debug: Finish (Step Out)")
			map("n", "c", dap.continue, "Debug: Continue")
		end

		local function disable_gdb_keys()
			pcall(vim.keymap.del, "n", "n")
			pcall(vim.keymap.del, "n", "s")
			pcall(vim.keymap.del, "n", "f")
			pcall(vim.keymap.del, "n", "c")
		end

		dap.listeners.after.event_initialized["dapui_config"] = function()
			dapui.open()
			enable_gdb_keys()
		end
		dap.listeners.before.event_terminated["dapui_config"] = function()
			disable_gdb_keys()
			dapui.close()
		end
		dap.listeners.before.event_exited["dapui_config"] = function()
			disable_gdb_keys()
			dapui.close()
		end

		dap.adapters.gdb = {
			type = "executable",
			command = "gdb",
			args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
		}

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
				args = {},
				cwd = "${workspaceFolder}",
				stopAtBeginningOfMainSubprogram = true,
			},
		}
		dap.configurations.c = {
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
				args = {},
				cwd = "${workspaceFolder}",
				stopAtBeginningOfMainSubprogram = true,
			},
		}

		map("n", "<leader>dc", dap.continue, "Debug: Continue/Start")
		map("n", "<leader>dt", function()
			dap.terminate()
			dapui.close()
		end, "Debug: Terminate")
		map("n", "<leader>dr", dap.repl.open, "Debug: Open REPL")
		map("n", "<leader>db", dap.toggle_breakpoint, "Debug: Toggle Breakpoint")
		map("n", "<leader>dB", function()
			dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
		end, "Debug: Conditional Breakpoint")
		map("n", "<leader>di", dap.step_into, "Debug: Step Into")
		map("n", "<leader>do", dap.step_over, "Debug: Step Over")
		map("n", "<leader>dO", dap.step_out, "Debug: Step Out")

		map("n", "<leader>dh", require("dapui").eval, "Debug: Hover (Eval)")

		map("n", "<leader>ds", function()
			local widgets = require("dap.ui.widgets")
			widgets.centered_float(widgets.scopes, { border = "rounded" })
		end, "Debug: Scopes")

		map("n", "<leader>du", dapui.toggle, "Debug: Toggle UI")

		map("n", "<leader>dr", dap.run_last, "Debug: Restart / Run Last")

		map("n", "<leader>dR", function()
			dap.terminate()
			vim.defer_fn(function()
				dap.continue()
			end, 200)
		end, "Debug: Hard Restart")
	end,
}
