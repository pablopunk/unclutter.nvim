local unclutter = require "unclutter.unclutter"
local tabline = require "unclutter.tabline"
local buffer = require "unclutter.buffer"
local telescope = require "unclutter.telescope"

---@class unclutter
local M = {}

--- handle tabline buffers
--- keep buffer in tabline
M.keep = tabline.keep_buffer

--- keep current buffer in tabline
function M.keep_current()
  tabline.keep_buffer(buffer.current())
end

--- keep current buffer in tabline
M.toggle = tabline.toggle_buffer

function M.toggle_current()
  tabline.toggle_buffer(buffer.current())
end

M.list = tabline.get_buffers

function M.hide()
  tabline.hide_buffer()
end

function M.hide_current()
  tabline.remove_buffer(buffer.current())
end

--- bnext & bprev
M.next = tabline.next
M.prev = tabline.prev

--- handle plugin (on/off)
M.enable = unclutter.enable
M.disable = unclutter.disable

--- telescope.nvim integration
M.telescope = telescope.open_buffers

--- Setup function (optional)
---@param opts unclutter.config
function M.setup(opts)
  unclutter.enable(opts)
end

return M
