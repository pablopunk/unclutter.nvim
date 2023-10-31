local unclutter = require "unclutter.unclutter"
local state = require "unclutter.state"
local buffer = require "unclutter.buffer"

unclutter.setup()

return {
  add_buffer = state.add,
  add_current_buffer = function()
    state.add(buffer.current())
  end,
  list_buffers = state.list,
  remove_buffer = state.remove,
}
