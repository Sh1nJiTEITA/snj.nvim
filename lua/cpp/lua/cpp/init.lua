---@module 'cpp'

---@class CppPlugin
---@field main import('cpp.cpp_funcs')
---@field lsp import('cpp.lsp')
---@field win import('cpp.win')
local M = {} -- typed table

-- assign submodules
M.main = require("cpp.cpp_funcs")
M.lsp = require("cpp.lsp")
M.win = require("cpp.win")

return M

-- ---@type { main: import("cpp.cpp_funcs"), lsp: import("cpp.lsp"), win: import("cpp.win") }
-- local M = {
--    main = require("cpp.cpp_funcs"),
--    lsp = require("cpp.lsp"),
--    win = require("cpp.win"),
-- }
-- return M

-- ---@module 'cpp'
-- ---@class CppPlugin
-- ---@field main fun(): 'cpp.cpp_funcs'
-- ---@field lsp fun(): 'cpp.lsp'
-- ---@field win fun(): 'cpp.win'
--
-- ---@type CppPlugin
-- local M = {
--
--    --- @module 'cpp.cpp_funcs'
--    main = require("cpp.cpp_funcs"),
--
--    --- @module 'cpp.lsp'
--    lsp = require("cpp.lsp"),
--
--    --- @module 'cpp.win'
--    win = require("cpp.win"),
-- }
--
-- return M
