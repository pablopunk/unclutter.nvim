local autocmds = require "unclutter.autocmds"
local buffer = require "unclutter.buf"
local state = require "unclutter.state"

local M = {}

-- Initialize the plugin
function M.setup()
  M.setup_autocmds()
end

-- Setup the autocmds
function M.setup_autocmds()
  autocmds.on_vim_enter(function()
    M.mark_all_open_buffers_as_relevant()
  end)
  autocmds.on_buf_enter(function()
    M.close_irrelevant_buffers()
  end)
  autocmds.on_buf_delete(function(event)
    state.remove(event.buf)
  end)
  autocmds.on_buf_write_post(function(event)
    if buffer.is_file(event.buf) then
      state.add(event.buf)
    end
  end)
  autocmds.on_buf_modified_set(function(event)
    if buffer.is_file(event.buf) then
      state.add(event.buf)
    end
  end)
  autocmds.on_win_enter(function()
    M.close_irrelevant_buffers()
  end)
end

-- Close all buffers that are not in the state nor visible
function M.close_irrelevant_buffers()
  local current_buffer = buffer.current()

  for _, buf in ipairs(buffer.all()) do
    if buf ~= current_buffer and not state.has(buf) and not buffer.has_windows(buf) then
      buffer.delete(buf)
    end
  end
end

-- Mark all open buffers as relevant
function M.mark_all_open_buffers_as_relevant()
  for _, buf in ipairs(buffer.all()) do
    state.add(buf)
  end
end

return M
