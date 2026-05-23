-- lua/tests/lsp_spec.lua

describe("C++ LSP (clangd) Tests", function()
	it("can fetch hover documentation for a C++ function", function()
		-- 1. Create a physical temporary file
		-- WHY: LSP servers like clangd rely on the filesystem. They often fail
		-- or act weirdly on virtual/unsaved Neovim buffers.
		local tmp_file = vim.fn.tempname() .. ".cpp"
		vim.fn.writefile({
			[[
                int add_apples(int a, int b) { return a + b; }
                int main() {
                  return add_apples(2, 3);
                }
            ]],
		}, tmp_file)

		-- 2. Open the file in Neovim
		vim.cmd("edit " .. tmp_file)
		local bufnr = vim.api.nvim_get_current_buf()

		local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
		vim.print(lines)

		-- 3. Start and attach clangd manually
		local client_id = vim.lsp.start({
			name = "clangd",
			cmd = { "clangd" },
			root_dir = vim.fn.getcwd(),
		})
		vim.lsp.buf_attach_client(bufnr, client_id)

		-- 4. WAIT for clangd to be fully ready (CRITICAL STEP)
		-- We give it up to 5 seconds (5000ms), checking every 100ms.
		local is_ready = vim.wait(5000, function()
			local clients = vim.lsp.get_clients({ bufnr = bufnr })
			for _, client in ipairs(clients) do
				if client.name == "clangd" and client.initialized then
					return true
				end
			end
			return false
		end, 100)

		-- If this fails, your machine might not have clangd installed in the PATH!
		assert.is_true(is_ready, "Clangd failed to start and initialize in time!")

		-- 5. Move the cursor to the word 'add_apples' inside main()
		-- Line 3 (index 2 in Lua API), Column 12
		vim.api.nvim_win_set_cursor(0, { 3, 12 })

		-- 6. Request Hover info SYNCHRONOUSLY
		-- Instead of messy callbacks, _sync pauses the test until clangd replies
		local params = vim.lsp.util.make_position_params(0)
		local result, err = vim.lsp.buf_request_sync(bufnr, "textDocument/hover", params, 2000)

		-- 7. Assertions
		assert.is_nil(err, "LSP request threw an error")
		assert.is_not_nil(result, "LSP returned no result")

		-- Extract the hover text from the raw LSP response payload
		local hover_data = result[client_id].result
		assert.is_not_nil(hover_data, "No hover data found for this position")

		local hover_text = hover_data.contents.value

		-- Check if clangd actually read our function signature
		-- We use string.find to check if the string contains our C++ definition
		local found_signature = string.find(hover_text, "int add_apples%(int a, int b%)")
		assert.is_not_nil(found_signature, "Hover text did not contain the correct C++ signature")

		-- 8. Cleanup (Be a good citizen and kill the server/file)
		vim.lsp.stop_client(client_id)
		vim.cmd("bdelete! " .. bufnr)
		vim.fn.delete(tmp_file)
	end)
end)
