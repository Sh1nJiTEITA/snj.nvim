-- local cached_binary = nil
-- local cached_args = nil
--
-- local function pick_binary(cb)
-- 	local actions = require("telescope.actions")
-- 	local action_state = require("telescope.actions.state")
--
-- 	require("telescope.builtin").find_files({
-- 		prompt_title = "Select Executable",
-- 		find_command = { "fd", "--hidden", "--no-ignore", "--type", "x" },
-- 		previewer = false,
-- 		attach_mappings = function(prompt_bufnr, map)
-- 			actions.select_default:replace(function()
-- 				local selection = action_state.get_selected_entry()
-- 				actions.close(prompt_bufnr)
-- 				cached_binary = selection[1]
-- 				cb(cached_binary)
-- 			end)
-- 			return true
-- 		end,
-- 	})
-- end
--
-- return {
-- 	"mfussenegger/nvim-dap",
-- 	dependencies = {
-- 		"rcarriga/nvim-dap-ui",
-- 		"nvim-neotest/nvim-nio",
-- 	},
-- 	config = function()
-- 		local dap = require("dap")
-- 		local dapui = require("dapui")
--
-- 		dapui.setup({
-- 			wrap = true,
-- 			floating = {
-- 				max_width = 80,
-- 				max_height = 20,
-- 				border = "rounded",
-- 				mappings = {
-- 					close = { "q", "<Esc>" },
-- 				},
-- 			},
-- 			layouts = {
-- 				{
-- 					-- LEFT PANEL
-- 					position = "left",
-- 					size = 50,
-- 					elements = {
-- 						{ id = "breakpoints", size = 0.1 },
-- 						{ id = "scopes", size = 0.3 },
-- 						{ id = "watches", size = 0.6 },
-- 					},
-- 				},
-- 				{
-- 					-- RIGHT PANEL
-- 					position = "bottom",
-- 					size = 15,
-- 					elements = {
-- 						{ id = "repl", size = 0.5 },
-- 						{ id = "console", size = 0.5 },
-- 					},
-- 				},
-- 			},
-- 		})
--
-- 		local map = function(mode, lhs, rhs, desc)
-- 			vim.keymap.set(mode, lhs, rhs, { desc = desc, silent = true })
-- 		end
--
-- 		local function enable_gdb_keys()
-- 			map("n", "n", dap.step_over, "Debug: Next (Step Over)")
-- 			map("n", "s", dap.step_into, "Debug: Step (Step Into)")
-- 			map("n", "f", dap.step_out, "Debug: Finish (Step Out)")
-- 			map("n", "c", dap.continue, "Debug: Continue")
-- 			map("n", "u", dap.up, "Debug: Up Stack")
-- 			map("n", "d", dap.down, "Debug: Down Stack")
-- 		end
--
-- 		local function disable_gdb_keys()
-- 			pcall(vim.keymap.del, "n", "n")
-- 			pcall(vim.keymap.del, "n", "s")
-- 			pcall(vim.keymap.del, "n", "f")
-- 			pcall(vim.keymap.del, "n", "c")
-- 			pcall(vim.keymap.del, "n", "u")
-- 			pcall(vim.keymap.del, "n", "d")
-- 		end
--
-- 		dap.listeners.after.event_initialized["dapui_config"] = function()
-- 			dapui.open()
-- 			enable_gdb_keys()
-- 		end
-- 		dap.listeners.before.event_terminated["dapui_config"] = function()
-- 			disable_gdb_keys()
-- 		end
-- 		dap.listeners.before.event_exited["dapui_config"] = function()
-- 			disable_gdb_keys()
-- 		end
--
-- 		dap.adapters.gdb = {
-- 			type = "executable",
-- 			command = "gdb",
-- 			args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
-- 		}
--
-- 		dap.configurations.cpp = {
-- 			{
-- 				name = "Launch",
-- 				type = "gdb",
-- 				request = "launch",
-- 				program = function()
-- 					return coroutine.create(function(coro)
-- 						if cached_binary then
-- 							coroutine.resume(coro, cached_binary)
-- 						else
-- 							pick_binary(function(path)
-- 								coroutine.resume(coro, path)
-- 							end)
-- 						end
-- 					end)
-- 				end,
-- 				args = function()
-- 					if cached_args then
-- 						return cached_args
-- 					end
--
-- 					local args_string = vim.fn.input("Arguments: ")
-- 					if args_string == "" then
-- 						cached_args = {}
-- 					else
-- 						cached_args = vim.split(args_string, "%s+")
-- 					end
-- 					return cached_args
-- 				end,
-- 				setupCommands = {
-- 					{
-- 						text = "set scheduler-locking on",
-- 						description = "Lock other threads while stepping",
-- 						ignoreFailures = false,
-- 					},
-- 					{
-- 						text = "set print thread-events off",
-- 						description = "Silence thread noise",
-- 						ignoreFailures = true,
-- 					},
-- 					{
-- 						text = "set max-value-size 1024", -- LIMITS JSON DATA SIZE
-- 						description = "Don't allow GDB to expand massive objects in RAM",
-- 						ignoreFailures = true,
-- 					},
-- 					{
-- 						text = "disable pretty-printer", -- DISABLES THE PYTHON JSON CRASH
-- 						description = "Turn off buggy python pretty printers",
-- 						ignoreFailures = true,
-- 					},
-- 				},
-- 				cwd = "${workspaceFolder}",
-- 				stopAtBeginningOfMainSubprogram = true,
-- 			},
-- 		}
--
-- 		-- Standard Execution Control
-- 		map("n", "<leader>dc", dap.continue, "Debug: Continue/Start")
-- 		map("n", "<leader>dt", function()
-- 			dap.terminate()
-- 			dapui.close()
-- 		end, "Debug: Terminate")
--
-- 		-- Breakpoints
-- 		map("n", "<leader>db", dap.toggle_breakpoint, "Debug: Toggle Breakpoint")
-- 		map("n", "<leader>dB", function()
-- 			dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
-- 		end, "Debug: Conditional Breakpoint")
--
-- 		-- Stepping
-- 		map("n", "<leader>di", dap.step_into, "Debug: Step Into")
-- 		map("n", "<leader>do", dap.step_over, "Debug: Step Over")
-- 		map("n", "<leader>dO", dap.step_out, "Debug: Step Out")
--
-- 		-- UI & Evaluation
-- 		map("n", "<leader>dh", require("dapui").eval, "Debug: Hover (Eval)")
-- 		map("n", "<leader>dE", dap.repl.open, "Debug: Open REPL") -- Fixed duplicate keymap
-- 		map("n", "<leader>du", dapui.toggle, "Debug: Toggle UI")
-- 		map("n", "<leader>ds", function()
-- 			local widgets = require("dap.ui.widgets")
-- 			widgets.centered_float(widgets.scopes, { border = "rounded" })
-- 		end, "Debug: Scopes")
--
-- 		-- Restarts & Cache Management
-- 		map("n", "<leader>dr", dap.run_last, "Debug: Restart / Run Last")
-- 		map("n", "<leader>dR", function()
-- 			dap.terminate()
-- 			vim.defer_fn(function()
-- 				dap.continue()
-- 			end, 200)
-- 		end, "Debug: Hard Restart")
--
-- 		map("n", "<leader>dx", function()
-- 			cached_binary = nil
-- 			cached_args = nil
-- 			print("Debug cache cleared! Next run will prompt for binary and args.")
-- 		end, "Debug: Reset Binary and Args Cache")
--
-- 		map("n", "<leader>da", function()
-- 			local current_args_str = (cached_args and #cached_args > 0) and table.concat(cached_args, " ") or ""
-- 			local status, new_args_str = pcall(vim.fn.input, {
-- 				prompt = "Modify Arguments: ",
-- 				default = current_args_str,
-- 				cancelreturn = "__CANCEL__",
-- 			})
-- 			if status and new_args_str ~= "__CANCEL__" then
-- 				if new_args_str == "" then
-- 					cached_args = {}
-- 					print("Args cleared.")
-- 				else
-- 					cached_args = vim.split(new_args_str, "%s+", { trimempty = true })
-- 					print("Args updated: " .. new_args_str)
-- 				end
-- 			else
-- 				print("Modification cancelled. Args unchanged.")
-- 			end
-- 		end, "Debug: Modify Current Args")
--
-- 		map("n", "<leader>dw", function()
-- 			local session = dap.session()
-- 			if not session then
-- 				vim.notify("You must start a debug session first to set a watchpoint.", vim.log.levels.WARN)
-- 				return
-- 			end
--
-- 			local cur_word = vim.fn.expand("<cword>")
-- 			local expr = vim.fn.input("Watch (write) Expression: ", cur_word)
--
-- 			if expr ~= "" then
-- 				session:request("evaluate", {
-- 					expression = "watch " .. expr,
-- 					context = "repl",
-- 				}, function(err, _)
-- 					-- We must wrap the result in vim.schedule because the DAP
-- 					-- response comes back asynchronously outside the Neovim UI thread.
-- 					vim.schedule(function()
-- 						if err then
-- 							vim.notify("GDB error setting watchpoint for: " .. expr, vim.log.levels.ERROR)
-- 						else
-- 							vim.notify("GDB applied watchpoint: " .. expr, vim.log.levels.INFO)
-- 						end
-- 					end)
-- 				end)
-- 			end
-- 		end, "Debug: Watch Variable (Data Breakpoint)")
-- 	end,
-- }

local cached_binary = nil
local cached_args = nil

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
	{
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
						size = 50,
						elements = {
							{ id = "breakpoints", size = 0.1 },
							{ id = "scopes", size = 0.3 },
							{ id = "watches", size = 0.6 },
						},
					},
					{
						-- RIGHT PANEL
						position = "bottom",
						size = 15,
						elements = {
							{ id = "repl", size = 0.5 },
							{ id = "console", size = 0.5 },
						},
					},
				},
			})

			local map = function(mode, lhs, rhs, desc)
				vim.keymap.set(mode, lhs, rhs, { desc = desc, silent = true })
			end

			local function enable_debug_keys()
				map("n", "n", dap.step_over, "Debug: Next (Step Over)")
				map("n", "s", dap.step_into, "Debug: Step (Step Into)")
				map("n", "f", dap.step_out, "Debug: Finish (Step Out)")
				map("n", "c", dap.continue, "Debug: Continue")
				map("n", "[", dap.up, "Debug: Up Stack")
				map("n", "]", dap.down, "Debug: Down Stack")
			end

			local function disable_debug_keys()
				pcall(vim.keymap.del, "n", "n")
				pcall(vim.keymap.del, "n", "s")
				pcall(vim.keymap.del, "n", "f")
				pcall(vim.keymap.del, "n", "c")
				pcall(vim.keymap.del, "n", "[")
				pcall(vim.keymap.del, "n", "]")
			end

			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
				enable_debug_keys()
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				disable_debug_keys()
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				disable_debug_keys()
			end

			-- =========================================================
			-- LLDB ADAPTER SETUP
			-- =========================================================
			-- Note: If you are on an older LLVM version (< 17), the binary
			-- might be called 'lldb-vscode' instead of 'lldb-dap'.
			dap.adapters.lldb = {
				type = "executable",
				command = "lldb-dap-19",
				name = "lldb",
			}

			dap.configurations.cpp = {
				{
					name = "Launch (LLDB)",
					type = "lldb",
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
					stopOnEntry = false,
					-- LLDB uses 'initCommands' instead of setupCommands
					initCommands = {
						"settings set target.process.thread-messages false",
						"settings set target.max-children-count 256",
						"settings set target.enable-synthetic-value true",
						"settings set target.process.run-all-threads true",
					},
				},
			}

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
			map("n", "<leader>dh", require("dapui").eval, "Debug: Hover (Eval)")
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

			-- Refactored for LLDB Watchpoints
			map("n", "<leader>dw", function()
				local session = dap.session()
				if not session then
					vim.notify("You must start a debug session first to set a watchpoint.", vim.log.levels.WARN)
					return
				end

				local cur_word = vim.fn.expand("<cword>")
				local expr = vim.fn.input("Watch (write) Expression: ", cur_word)

				if expr ~= "" then
					-- LLDB requires the backtick ` to evaluate raw terminal commands in the DAP REPL,
					-- or just passing the raw command depending on context. We pass the native LLDB command.
					session:request("evaluate", {
						expression = "watchpoint set expression " .. expr,
						context = "repl",
					}, function(err, _)
						vim.schedule(function()
							if err then
								vim.notify("LLDB error setting watchpoint for: " .. expr, vim.log.levels.ERROR)
							else
								vim.notify("LLDB applied watchpoint: " .. expr, vim.log.levels.INFO)
							end
						end)
					end)
				end
			end, "Debug: Watch Variable (Data Breakpoint)")

			map("n", "<leader>dj", function()
				local session = dap.session()
				if not session then
					vim.notify("You must start a debug session first to dump JSON.", vim.log.levels.WARN)
					return
				end

				local var_name = vim.fn.expand("<cword>")

				if var_name == "" then
					vim.notify("No variable found under cursor.", vim.log.levels.WARN)
					return
				end

				-- Construct the magic LLDB command
				local cmd = string.format(
					"`p (void)printf(\"%%s\\n\", %s.dump(2, ' ', true, (nlohmann::detail::error_handler_t)2).c_str())",
					var_name
				)

				session:request("evaluate", {
					expression = cmd,
					context = "repl",
				}, function(err, _)
					vim.schedule(function()
						if err then
							vim.notify("LLDB error dumping JSON for: " .. var_name, vim.log.levels.ERROR)
						else
							vim.notify("Dumped " .. var_name .. " to program stdout!", vim.log.levels.INFO)
						end
					end)
				end)
			end, "Debug: Dump nlohmann::json to stdout (Instant)")
		end,
	},

	{
		"m00qek/baleia.nvim",
		version = "*",
		config = function()
			local baleia = require("baleia").setup({
				-- Optional: You can customize colors here if your theme needs it
			})

			-- Automatically strip ANSI and apply colors to dap-ui buffers
			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "dap-repl", "dapui_console" },
				callback = function(args)
					baleia.automatically(args.buf)
				end,
			})
		end,
	},
}
