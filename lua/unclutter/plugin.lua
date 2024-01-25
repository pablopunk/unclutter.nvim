local autocmds = require "unclutter.autocmds"
local buffer = require "unclutter.buffer"
local tabline = require "unclutter.tabline"
local config = require "unclutter.config"

---@class unclutter.plugin
local plugin = {}

---@type number
plugin.buf_just_left = nil
plugin.enabled = false

--- Initialize the plugin
---@param opts unclutter.config
function plugin.enable(opts)
  config.set(opts)

  if config.tabline == true then
    tabline.enable()
  else
    tabline.disable()
  end

  if plugin.enabled == false then -- don't do some stuff twice if setup() is called again
    plugin.setup_autocmds()
  end

  plugin.enabled = true
end

--- Disable the plugin
function plugin.disable()
  if plugin.enabled == false then
    return
  end

  autocmds.remove_augroup()
  tabline.disable()

  plugin.enabled = false
end

--- Setup the autocmds
function plugin.setup_autocmds()
  autocmds.on_buf_delete(function(event)
    tabline.remove_buffer(event.buf)
  end)
  autocmds.on_buf_leave(function(event)
    if plugin.buffer_should_be_hidden_on_leave(event.buf) then
      tabline.remove_buffer(event.buf)
    end
    plugin.buf_just_left = event.buf
  end)
  autocmds.on_buf_enter(function(event)
    if
      plugin.buf_just_left ~= nil
      and event.buf ~= plugin.buf_just_left
      and not tabline.is_buffer_kept(plugin.buf_just_left)
    then
      tabline.remove_buffer(plugin.buf_just_left)
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
    plugin.keep_all_buffers()
  end)
end

--- Check if buffer should be hidden
---@param buf number
---@return boolean
function plugin.buffer_should_be_hidden_on_leave(buf)
  return not tabline.is_buffer_kept(buf)
    and buffer.current() ~= buf
    and buffer.is_file(buf)
    and not buffer.is_visible(buf)
    and buffer.windows(buf) == 0
end

function plugin.keep_all_buffers()
  for _, buf in ipairs(buffer.all()) do
    tabline.keep_buffer(buf)
  end
end

return plugin
