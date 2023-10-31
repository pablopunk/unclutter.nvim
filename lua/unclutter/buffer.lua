local M = {}

-- Get the current buffer
M.current = function()
  return vim.api.nvim_get_current_buf()
end

-- Get the name of buffer
M.name = function(buf)
  return vim.api.nvim_buf_get_name(buf)
end

-- Get the buftype of buffer
M.type = function(buf)
  return vim.api.nvim_get_option_value("buftype", { buf = buf })
end

-- Check if buffer is a file
M.is_file = function(buf)
  return M.type(buf) == "" and M.name(buf) ~= ""
end

-- Delete buffer
M.delete = function(buf)
  return vim.api.nvim_buf_delete(buf, { force = true })
end

-- Return if the buffer is found in a window
M.has_windows = function(buf)
  local buffer_windows = vim.fn.win_findbuf(buf)
  return #buffer_windows > 0
end

-- Return a list of all file buffers
M.all = function()
  local buffers = vim.tbl_filter(function(buf)
    return M.is_file(buf) and vim.api.nvim_buf_is_valid(buf)
  end, vim.api.nvim_list_bufs())

  return buffers
end

return M
