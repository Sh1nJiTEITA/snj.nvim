-- 1. This is the "code" we are testing (usually this is in another file)
local my_plugin = {
	add = function(a, b)
		return a + b
	end,

	set_buffer_text = function(text)
		vim.api.nvim_buf_set_lines(0, 0, -1, false, { text })
	end,
}

-- 2. The Test Suite
describe("My Baby's First Plugin", function()
	-- Test 1: Simple Logic
	it("can add two numbers correctly", function()
		local result = my_plugin.add(2, 2)

		-- Assertions check if reality matches your expectations
		assert.are.same(4, result)
	end)

	-- Test 2: Neovim API Side Effects
	it("can change the text in a buffer", function()
		local expected_text = "Hello Neovim!"

		my_plugin.set_buffer_text(expected_text)

		-- Get the first line of the current buffer
		local current_line = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1]

		assert.are.same(expected_text, current_line)
	end)
end)
