local unclutter = require "unclutter.unclutter"
local state = require "unclutter.state"
local buffer = require "unclutter.buffer"

return {
  -- handle buffers
  add_buffer = state.add,
  add_current_buffer = function()
    state.add(buffer.current())
  end,
  toggle_buffer = state.toggle,
  toggle_current_buffer = function()
    state.toggle(buffer.current())
  end,
  list_buffers = state.list,
  remove_buffer = state.remove,

  -- handle plugin (on/off)
  enable = unclutter.enable,
  disable = unclutter.disable,

  -- init function
  ---@param opts SetupOpts
  setup = function(opts)
    unclutter.enable(opts)
  end,
}
