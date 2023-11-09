local autocmds = require "unclutter.autocmds"
local buffer = require "unclutter.buffer"
local tabline = require "unclutter.tabline"

local M = {}

---@type number
M.buf_just_left = nil

-- Initialize the plugin
function M.enable()
  M.setup_autocmds()
  tabline.enable()
end

-- Disable the plugin
function M.disable()
  autocmds.remove_augroup()
  tabline.disable()
end

-- Setup the autocmds
function M.setup_autocmds()
  autocmds.on_tabline_should_be_updated(function()
    tabline.update()
  end)
  autocmds.on_buf_leave(function(event)
    if M.buffer_should_be_hidden(event.buf) then
      tabline.remove_buffer(event.buf)
    end
    M.buf_just_left = event.buf
  end)
  autocmds.on_buf_enter(function(event)
    if M.buf_just_left ~= nil and event.buf ~= M.buf_just_left and M.buffer_should_be_hidden(M.buf_just_left) then
      tabline.remove_buffer(M.buf_just_left)
    end
  end)
  autocmds.on_buf_write_post(function(event)
    if buffer.is_file(event.buf) then
      tabline.keep_buffer(event.buf)
    end
  end)
  autocmds.on_buf_modified_set(function(event)
    if buffer.is_file(event.buf) then
      tabline.keep_buffer(event.buf)
    end
  end)
  autocmds.on_vim_enter(function()
    M.keep_all_buffers()
  end)
end

-- Check if buffer should be hidden
---@param buf number
---@return boolean
function M.buffer_should_be_hidden(buf)
  return buffer.current() ~= buf
    and not tabline.is_buffer_kept(buf)
    and buffer.is_file(buf)
    and not buffer.is_visible(buf)
    and buffer.windows(buf) == 0
end

function M.keep_all_buffers()
  for _, buf in ipairs(buffer.all()) do
    tabline.keep_buffer(buf)
  end
end

return M
