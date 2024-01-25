---@class unclutter.buffer
local buffer = {}

--- Get the current buffer
---@return number
buffer.current = function()
  local _, buf = pcall(vim.api.nvim_get_current_buf)
  return buf
end

--- Get the buffer number of the file
---@param file_path string
---@return number|nil
buffer.number = function(file_path)
  local ok, buf = pcall(vim.fn.bufnr, file_path)
  if not ok then
    return nil
  end
  return buf
end

--- Get the name of buffer
---@param buf number
---@return string
buffer.name = function(buf)
  local ok, name = pcall(vim.api.nvim_buf_get_name, buf)
  if not ok then
    return ""
  end
  return name
end

--- Get the buftype of buffer
---@param buf number
---@return string
buffer.type = function(buf)
  local ok, buftype = pcall(vim.api.nvim_get_option_value, "buftype", { buf = buf })
  if not ok then
    return "errored"
  end
  return buftype
end

--- Delete buffer
---@param buf number
---@return boolean
buffer.delete = function(buf)
  return pcall(vim.api.nvim_buf_delete, buf, { force = true })
end

--- Unload buffer
---@param buf number
---@return boolean
buffer.unload = function(buf)
  return pcall(function()
    vim.cmd("silent! bunload " .. buf)
  end, buf)
end

--- Check if buffer is a file
---@param buf number
---@return boolean
buffer.is_file = function(buf)
  return buffer.type(buf) == "" and buffer.name(buf) ~= ""
end

--- Return number of windows where buffer is open
---@param buf number
---@return number
buffer.windows = function(buf)
  local ok, buffer_windows = pcall(vim.fn.win_findbuf, buf)
  if not ok then
    return 0
  end
  return #buffer_windows
end

--- Check if buffer is visible in current tab
---@param buf number
---@return boolean
buffer.is_visible = function(buf)
  local ok, tab_buffers = pcall(vim.fn.tabpagebuflist)
  if not ok then
    return false
  end
  return vim.tbl_contains(tab_buffers, buf)
end

--- Check if buffer is valid
---@param buf number
---@return boolean
buffer.is_valid = function(buf)
  local ok, valid = pcall(vim.api.nvim_buf_is_valid, buf)
  return ok and valid
end

--- Check if buffer is loaded
---@param buf number
---@return boolean
buffer.is_loaded = function(buf)
  local ok, loaded = pcall(vim.api.nvim_buf_is_loaded, buf)
  return ok and loaded
end

--- Check if buffer is listed
---@param buf number
---@return boolean
buffer.listed = function(buf)
  return vim.bo[buf].buflisted
end

--- Return all listed buffers + the current buffer (even if it's not listed)
---@return table
buffer.all = function()
  local buf_list = vim.api.nvim_list_bufs()
  local listed_buffers = vim.tbl_filter(buffer.listed, buf_list)
  local current_buf = buffer.current()

  -- add current buffer to list if it's not listed
  if not vim.tbl_contains(listed_buffers, current_buf) then
    table.insert(listed_buffers, current_buf)
  end

  return listed_buffers
end

return buffer
