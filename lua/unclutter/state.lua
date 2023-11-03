local buffer = require "unclutter.buffer"

local M = {
  buffers = {}, -- table of buffers
}

-- Get the id key for a buffer
---@param buf number
---@return string
function M.key_for_buf(buf)
  return buffer.name(buf)
end

-- Get the value for a buffer
---@param buf number
---@return table
function M.value_for_buf(buf)
  return {
    bufnr = buf, -- buffer number
  }
end

-- Add a buffer to the state
---@param buf number
function M.add(buf)
  M.buffers[M.key_for_buf(buf)] = M.value_for_buf(buf)
end

-- Check if a buffer is in the state
---@param buf number
---@return boolean
function M.has(buf)
  return M.buffers[M.key_for_buf(buf)] ~= nil
end

-- Remove a buffer from the state
---@param buf number
function M.remove(buf)
  M.buffers[M.key_for_buf(buf)] = nil
end

-- Toggle a buffer in the state
---@param buf number
function M.toggle(buf)
  if M.has(buf) then
    M.remove(buf)
  else
    M.add(buf)
  end
end

-- List buffers in state
---@return table
function M.list()
  local list = {}
  for key, value in pairs(M.buffers) do
    table.insert(list, {
      bufnr = value.bufnr,
      name = key,
    })
  end
  return list
end

return M
