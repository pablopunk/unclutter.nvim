local M = {}

-- Get the current buffer
---@return number
M.current = function()
  local _, buf = pcall(vim.api.nvim_get_current_buf)
  return buf
end

-- Get the name of buffer
---@param buf number
---@return string
M.name = function(buf)
  local ok, name = pcall(vim.api.nvim_buf_get_name, buf)
  if not ok then
    return ""
  end
  return name
end

-- Get the buftype of buffer
---@param buf number
---@return string
M.type = function(buf)
  local ok, buftype = pcall(vim.api.nvim_get_option_value, "buftype", { buf = buf })
  if not ok then
    return "errored"
  end
  return buftype
end

-- Delete buffer
---@param buf number
---@return boolean
M.delete = function(buf)
  return pcall(vim.api.nvim_buf_delete, buf, { force = true })
end

-- Unload buffer
---@param buf number
---@return boolean
M.unload = function(buf)
  return pcall(function()
    vim.cmd("silent! bunload " .. buf)
  end, buf)
end

-- Check if buffer is a file
---@param buf number
---@return boolean
M.is_file = function(buf)
  return M.type(buf) == "" and M.name(buf) ~= ""
end

-- Return number of windows where buffer is open
---@param buf number
---@return number
M.windows = function(buf)
  local ok, buffer_windows = pcall(vim.fn.win_findbuf, buf)
  if not ok then
    return 0
  end
  return #buffer_windows
end

-- Check if buffer is visible in current tab
---@param buf number
---@return boolean
M.is_visible = function(buf)
  local ok, tab_buffers = pcall(vim.fn.tabpagebuflist)
  if not ok then
    return false
  end
  return vim.tbl_contains(tab_buffers, buf)
end

-- Check if buffer is valid
---@param buf number
---@return boolean
M.is_valid = function(buf)
  local ok, valid = pcall(vim.api.nvim_buf_is_valid, buf)
  return ok and valid
end

-- Check if buffer is loaded
---@param buf number
---@return boolean
M.is_loaded = function(buf)
  local ok, loaded = pcall(vim.api.nvim_buf_is_loaded, buf)
  return ok and loaded
end

-- Check if buffer is listed
---@param buf number
---@return boolean
M.listed = function(buf)
  return vim.bo[buf].buflisted
end

-- Check if buffer is in tab
---@param buf number
---@param tab? number -- If not supplied, current tab is used
M.is_in_tab = function(buf, tab)
  if tab == nil then
    tab = vim.api.nvim_get_current_tabpage()
  end
  local tabpage_buffers = vim.api.nvim_tabpage_list_wins(tab)
  for _, winid in ipairs(tabpage_buffers) do
    local bufnr = vim.api.nvim_win_get_buf(winid)
    if vim.api.nvim_buf_is_loaded(bufnr) then
      if bufnr == buf then
        return true
      end
    end
  end

  local ok, tab_buffers = pcall(vim.fn.tabpagebuflist, tab)
  if not ok then
    return false
  end
  return vim.tbl_contains(tab_buffers, buf)
end

-- Return a list of all buffers
---@param tab? number
---@return table
M.all = function(tab) ---@TODO: Only buffers in `tab`
  local buf_list = vim.api.nvim_list_bufs()
  local listed_buffers = vim.tbl_filter(M.listed, buf_list)
  local current_buf = M.current()

  -- add current buffer to list if it's not listed
  if not vim.tbl_contains(listed_buffers, current_buf) then
    table.insert(listed_buffers, current_buf)
  end

  return listed_buffers
end

return M
