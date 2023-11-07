local autocmds = require "unclutter.autocmds"
local buffer = require "unclutter.buffer"
local state = require "unclutter.state"
local config = require "unclutter.config"

local M = {}

---@type number
M.buf_just_left = nil

-- Initialize the plugin
---@param opts SetupOpts
function M.enable(opts)
  config.init(opts)
  M.setup_autocmds()
  M.setup_keymaps()
end

-- Disable the plugin
function M.disable()
  autocmds.remove_augroup()
  M.remove_keymaps()
end

-- Setup keymaps
function M.setup_keymaps()
  if config.hijack_jumplist == false then
    return
  end
  vim.keymap.set("n", "<c-o>", function()
    M.go_to_most_recent_file()
  end, { noremap = true, silent = true, desc = "Jump to previous mark or file (unclutter.nvim)" })
end

-- Remove keymaps
function M.remove_keymaps()
  vim.keymap.del("n", "<c-o>")
end

-- Setup the autocmds
function M.setup_autocmds()
  autocmds.on_vim_enter(function()
    M.mark_all_open_buffers_as_relevant()
  end)
  autocmds.on_buf_leave(function(event)
    if M.buffer_should_be_closed(event.buf) then
      M.close_buffer(event.buf)
    end
    M.buf_just_left = event.buf
  end)
  autocmds.on_buf_enter(function(event)
    if M.buf_just_left ~= nil and event.buf ~= M.buf_just_left and M.buffer_should_be_closed(M.buf_just_left) then
      M.close_buffer(M.buf_just_left)
    end
  end)
  autocmds.on_buf_delete(function(event)
    state.remove(event.buf)
  end)
  autocmds.on_buf_write_post(function(event)
    if buffer.is_file(event.buf) then
      state.add(event.buf)
    end
  end)
  autocmds.on_buf_modified_set(function(event)
    if buffer.is_file(event.buf) then
      state.add(event.buf)
    end
  end)
end

-- Close buffer. It includes removing it from the buffer list
-- and other necessary actions.
---@param buf number
function M.close_buffer(buf)
  buffer.delete(buf)
end

-- Check if buffer should be closed
---@param buf number
---@return boolean
function M.buffer_should_be_closed(buf)
  return buffer.current() ~= buf
    and buffer.is_file(buf)
    and not state.has(buf)
    and not buffer.is_visible(buf)
    and buffer.windows(buf) == 0
end

-- Mark all open buffers as relevant
function M.mark_all_open_buffers_as_relevant()
  for _, buf in ipairs(buffer.all()) do
    state.add(buf)
  end
end

function M.go_to_most_recent_file()
  local current_file = buffer.name(buffer.current())
  for _, file in ipairs(vim.v.oldfiles) do
    local file_stat = vim.loop.fs_stat(file)
    if file_stat and file_stat.type == "file" and file ~= current_file then
      return vim.cmd("edit " .. file)
    end
  end
end

return M
