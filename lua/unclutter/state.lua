local buffer = require "unclutter.buf"

local M = {
  buffers = {},
}

-- Get the id key for a buffer
function M.key_for_buf(buf)
  return buffer.name(buf)
end

-- Add a buffer to the state
function M.add(buf)
  M.buffers[M.key_for_buf(buf)] = true
end

-- Check if a buffer is in the state
function M.has(buf)
  return M.buffers[M.key_for_buf(buf)] == true
end

-- Remove a buffer from the state
function M.remove(buf)
  M.buffers[M.key_for_buf(buf)] = nil
end

return M
