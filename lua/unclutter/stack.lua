local M = {}

M.stack = {}

-- Push value to stack
---@param value string
function M.push(value)
  table.insert(M.stack, value)
end

-- Pop value from stack
---@return string
function M.pop()
  return table.remove(M.stack)
end

-- Check if stack is empty
---@return boolean
function M.empty()
  return #M.stack == 0
end

return M
