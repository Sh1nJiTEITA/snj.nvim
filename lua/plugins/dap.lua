return {
   {
      "Shatur/neovim-cmake",
      dap_configuration = {
         type = "codelldb",
         request = "launch",
         stopOnEntry = false,
         runInTerminal = false,
      },
   },
   {
      "rcarriga/nvim-dap-ui",
      event = "VeryLazy",
      dependencies = {
         "mfussenegger/nvim-dap",
      },
      config = function()
         local dap = require("dap")
         local dapui = require("dapui")
         dap.listeners.after.event_initialized["dapui_config"] = function()
            dapui.open()
         end

         dap.listeners.before.event_terminated["dapui_config"] = function()
            dapui.close()
         end

         dap.listeners.before.event_exited["dapui_config"] = function()
            dapui.close()
         end

         require("dapui").setup()
      end,
   },
   {
      "mfussenegger/nvim-dap",
      dependencies = {
         "nvim-neotest/nvim-nio",
      },
      config = function()
         local dap = require("dap")

         vim.keymap.set("n", "<F5>", dap.continue, { desc = "Dap: Continue" })
         vim.keymap.set("n", "<F2>", dap.step_over, { desc = "Dap: Step Over" })
         vim.keymap.set("n", "<F1>", dap.step_into, { desc = "Dap: Step Into" })
         vim.keymap.set("n", "<F3>", dap.step_out, { desc = "Dap: Step Out" })
         vim.keymap.set("n", "<F4>", dap.terminate, { desc = "Dap: Terminate" })
         vim.keymap.set("n", "<Leader>b", dap.toggle_breakpoint, { desc = "Dap: Toggle Breakpoint" })
         vim.keymap.set("n", "<Leader>B", function()
            dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
         end, { desc = "Dap: Conditional Breakpoint" })
         vim.keymap.set("n", "<Leader>lp", function()
            dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
         end, { desc = "Dap: Log Point" })
         vim.keymap.set("n", "<Leader>dr", dap.repl.open, { desc = "Dap: Open REPL" })
         vim.keymap.set("n", "<Leader>dl", dap.run_last, { desc = "Dap: Run Last" })

         dap.configurations.cpp = {
            {
               name = "Launch",
               type = "codelldb",
               request = "launch",
               program = function()
                  local path = vim.g.dap_cpp_path
                  if path == nil then
                     path = vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
                     vim.g.dap_cpp_path = path
                  end
                  return path
               end,
               cwd = "${workspaceFolder}",
               stopOnEntry = false,
               args = {},
            },
         }
      end,
   },
}
