local autocmds = require "unclutter.autocmds"
local buffer = require "unclutter.buffer"
local tabline = require "unclutter.tabline"
local config = require "unclutter.config"

local M = {}

---@type number
M.buf_just_left = nil
M.enabled = false

-- Initialize the plugin
---@param opts Config
function M.enable(opts)
  config.set(opts)

  if config.tabline == true then
    tabline.enable()
  else
    tabline.disable()
  end

  if M.enabled == false then -- don't do some stuff twice if setup() is called again
    M.setup_autocmds()
  end

  M.enabled = true
end

-- Disable the plugin
function M.disable()
  if M.enabled == false then
    return
  end

  autocmds.remove_augroup()
  tabline.disable()

  M.enabled = false
end

-- Setup the autocmds
function M.setup_autocmds()
  autocmds.on_buf_delete(function(event)
    tabline.remove_buffer(event.buf)
  end)
  autocmds.on_buf_leave(function(event)
    if M.buffer_should_be_hidden_on_leave(event.buf) then
      tabline.remove_buffer(event.buf)
    end
    M.buf_just_left = event.buf
  end)
  autocmds.on_buf_enter(function(event)
    if M.buf_just_left ~= nil and event.buf ~= M.buf_just_left and not tabline.is_buffer_kept(M.buf_just_left) then
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
function M.buffer_should_be_hidden_on_leave(buf)
  return not tabline.is_buffer_kept(buf)
    and buffer.current() ~= buf
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
