local autocmds = require "unclutter.autocmds"
local buffer = require "unclutter.buffer"
local state = require "unclutter.state"

local M = {}

M.buf_just_left = nil

-- Initialize the plugin
function M.enable()
  M.setup_autocmds()
end

-- Disable the plugin
function M.disable()
  autocmds.remove_augroup()
end

-- Setup the autocmds
function M.setup_autocmds()
  autocmds.on_vim_enter(function()
    M.mark_all_open_buffers_as_relevant()
  end)
  autocmds.on_buf_leave(function(event)
    if M.buffer_should_be_closed(event.buf) then
      buffer.delete(event.buf)
    end
    M.buf_just_left = event.buf
  end)
  autocmds.on_buf_enter(function(event)
    if M.buf_just_left ~= nil and event.buf ~= M.buf_just_left and M.buffer_should_be_closed(M.buf_just_left) then
      buffer.delete(M.buf_just_left)
    end
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
end

-- Check if buffer should be closed
function M.buffer_should_be_closed(buf)
  return buffer.current() ~= buf
    and buffer.is_file(buf)
    and not state.has(buf)
    and not buffer.is_visible(buf)
    and buffer.windows(buf) == 0
end

-- Mark all open buffers as relevant
function M.mark_all_open_buffers_as_relevant()
  for _, buf in ipairs(buffer.all()) do
    state.add(buf)
  end
end

return M
