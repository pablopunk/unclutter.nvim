local M = {}

-- Get the current buffer
M.current = function()
  local ok, buf = pcall(vim.api.nvim_get_current_buf)
  if not ok then
    return nil
  end
  return buf
end

-- Get the name of buffer
M.name = function(buf)
  local ok, name = pcall(vim.api.nvim_buf_get_name, buf)
  if not ok then
    return ""
  end
  return name
end

-- Get the buftype of buffer
M.type = function(buf)
  local ok, buftype = pcall(vim.api.nvim_buf_get_option, buf, "buftype")
  if not ok then
    return "errored"
  end
  return buftype
end

-- Delete buffer
M.delete = function(buf)
  return pcall(vim.api.nvim_buf_delete, buf, { force = true })
end

-- Check if buffer is a file
M.is_file = function(buf)
  return M.type(buf) == "" and M.name(buf) ~= ""
end

-- Return number of windows where buffer is open
M.windows = function(buf)
  local ok, buffer_windows = pcall(vim.fn.win_findbuf, buf)
  if not ok then
    return 0
  end
  return #buffer_windows
end

-- Check if buffer is visible in current tab
M.is_visible = function(buf)
  local ok, tab_buffers = pcall(vim.fn.tabpagebuflist)
  if not ok then
    return false
  end
  return vim.tbl_contains(tab_buffers, buf)
end

-- Check if buffer is valid
M.is_valid = function(buf)
  local ok, valid = pcall(vim.api.nvim_buf_is_valid, buf)
  return ok and valid
end

-- Return a list of all file buffers
M.all = function()
  local buffers = vim.tbl_filter(function(buf)
    return M.is_file(buf) and M.is_valid(buf)
  end, vim.api.nvim_list_bufs())

  return buffers
end

return M
