--- @source 'cpp/cpp_funcs'
local main = require("cpp.cpp_funcs")

--- @source 'cpp/lsp'
local lsp = require("cpp.lsp")

--- @source 'cpp/win'
local win = require("cpp.win")

local M = {
   main = main,
   lsp = lsp,
   win = win,
}

return M
