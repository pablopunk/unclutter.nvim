local plugin = require "unclutter.plugin"
local tabline = require "unclutter.tabline"
local buffer = require "unclutter.buffer"
local telescope = require "unclutter.telescope"

---@class unclutter
local unclutter = {}

--- handle tabline buffers
--- keep buffer in tabline
unclutter.keep = tabline.keep_buffer

--- keep current buffer in tabline
function unclutter.keep_current()
  tabline.keep_buffer(buffer.current())
end

--- keep current buffer in tabline
unclutter.toggle = tabline.toggle_buffer

function unclutter.toggle_current()
  tabline.toggle_buffer(buffer.current())
end

unclutter.list = tabline.get_buffers
unclutter.hide = tabline.remove_buffer

function unclutter.hide_current()
  tabline.remove_buffer(buffer.current())
end

--- bnext & bprev
unclutter.next = tabline.next
unclutter.prev = tabline.prev

--- handle plugin (on/off)
unclutter.enable = plugin.enable
unclutter.disable = plugin.disable

--- telescope.nvim integration
unclutter.telescope = telescope.open_buffers

--- Setup function (optional)
---@param opts unclutter.config
function unclutter.setup(opts)
  unclutter.enable(opts)
end

return unclutter
