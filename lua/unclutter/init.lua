local unclutter = require "unclutter.unclutter"
local tabline = require "unclutter.tabline"
local buffer = require "unclutter.buffer"
local telescope = require "unclutter.telescope"

return {
  -- handle tabline buffers
  keep = tabline.keep_buffer,
  keep_current = function()
    tabline.keep_buffer(buffer.current())
  end,
  toggle = tabline.toggle_buffer,
  toggle_current = function()
    tabline.toggle_buffer(buffer.current())
  end,
  list = tabline.get_buffers,
  hide = tabline.hide_buffer,
  hide_current = function()
    tabline.remove_buffer(buffer.current())
  end,

  -- bnext & bprev
  next = tabline.next,
  prev = tabline.prev,

  -- handle plugin (on/off)
  enable = unclutter.enable,
  disable = unclutter.disable,

  -- telescope.nvim integration
  telescope = telescope.open_buffers,
  ---@param opts table
  setup = function(opts)
    unclutter.enable(opts)
  end,
}
