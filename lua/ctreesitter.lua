local func = require("vim.func")
---@param buf integer
---@param language string
local try_attach = function(buf, language)
	if not vim.treesitter.language.add(language) then
		return
	end

	vim.treesitter.start(buf, language)

	local has_indent_query = vim.treesitter.query.get(language, "indents") ~= nil

	if has_indent_query then
		vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
	end
end

local add_attach_cmd = function()
	local module = require("nvim-treesitter")
	local available_parsers = module.get_available()

	vim.api.nvim_create_autocmd("FileType", {
		callback = function(args)
			local buf = args.buf
			local filetype = args.match

			local lang = vim.treesitter.language.get_lang(filetype)
			if not lang then
				return
			end

			local installed_parsers = module.get_installed("parsers")

			if vim.tbl_contains(installed_parsers, lang) then
				try_attach(buf, lang)
			elseif vim.tbl_contains(available_parsers, lang) then
				module.install(lang):await(function()
					try_attach(buf, lang)
				end)
			else
				try_attach(buf, lang)
			end
		end,
	})
end

return {
	gh = "nvim-treesitter/nvim-treesitter",
	version = "main",
	config = function()
		local module = require("nvim-treesitter")

		local parsers = {
			"bash",
			"c",
			"diff",
			"html",
			"lua",
			"luadoc",
			"markdown",
			"markdown_inline",
			"query",
			"vim",
			"vimdoc",
			"comment",
			"cpp",
			"doxygen",
		}

		module.install(parsers)
	end,
}
