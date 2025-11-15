--- @module 'cpp.win'

--- @class CppWin
local M = {}

local utils = require("cpp.utils")
local lsp = require("cpp.lsp")

--- @class ScopeUIData
--- @field win_infos {intr_win_info: WindowCreationInfo, view_win_info: WindowCreationInfo }

--- @class ScopeUI
--- @field new fun(): ScopeUI
--- @field data ScopeUIData

local ScopeUI = {}
ScopeUI.__index = ScopeUI

--- @return { intr_win_sz: WindowSize, view_win_sz: WindowSize }
local function calc_scope_ui_win_szs()
   local calculated = utils.calc_centered_win_sz()
   local intr_w = 3

   return {
      intr_win_sz = { --- @type WindowSize
         row = calculated.row,
         col = calculated.col,
         width = intr_w,
         height = calculated.height,
      },
      view_win_sz = { --- @type WindowSize
         row = calculated.row,
         col = calculated.col + intr_w + 2,
         width = calculated.width - intr_w - 2,
         height = calculated.height,
      },
   }
end

local function create_ui_windows()
   local shared_config = {
      relative = "editor",
      border = "rounded",
      style = "minimal",
   }

   local szs = utils.calc_scope_ui_win_szs()
   local intr_win_info = utils.create_window(szs.view_win_sz, shared_config)
   local view_win_info = utils.create_window(szs.view_win_sz, shared_config)
   vim.api.nvim_buf_set_option(view_win_info.buf, "filetype", "cpp")

   local cleanup = function()
      --- @param window_info WindowCreationInfo
      local cleanup_win = function(window_info)
         if vim.api.nvim_win_is_valid(window_info.win) then
            vim.api.nvim_win_close(window_info.win, true)
         end

         if vim.api.nvim_buf_is_valid(window_info.buf) then
            vim.api.nvim_buf_delete(window_info.buf, { force = true })
         end
      end

      cleanup_win(intr_win_info)
      cleanup_win(view_win_info)
   end

   vim.api.nvim_set_current_win(intr_win_info.win)
   vim.api.nvim_create_autocmd({ "BufHidden", "BufLeave" }, {
      buffer = intr_win_info.buf,
      callback = cleanup,
   })

   vim.api.nvim_create_autocmd({ "VimResized" }, {
      callback = function()
         --- @param win_info WindowCreationInfo
         --- @param win_sz WindowSize
         local update_win_sz = function(win_info, win_sz)
            win_info = vim.tbl_extend("force", win_info, win_sz)
            local config = vim.tbl_extend("force", win_sz, shared_config)
            vim.api.nvim_win_set_config(win_info.win, config)
         end

         szs = calc_scope_ui_win_szs()
         update_win_sz(intr_win_info, szs.intr_win_sz)
         update_win_sz(view_win_info, szs.view_win_sz)
      end,
   })

   vim.api.nvim_buf_set_keymap(intr_win_info.buf, "n", "q", "", { callback = cleanup })

   return {
      intr_win_info = intr_win_info, --- @type WindowCreationInfo
      view_win_info = view_win_info, --- @type WindowCreationInfo
   }
end

function ScopeUI:new()
   local self = setmetatable({}, ScopeUI)
   self.data = {
      win_infos = create_ui_windows(),
   }
   return self
end

return M
