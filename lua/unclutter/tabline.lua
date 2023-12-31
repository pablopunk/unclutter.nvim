local buffer = require "unclutter.buffer"
local has_icons, icons = pcall(require, "nvim-web-devicons")
local config = require "unclutter.config"

local M = {}

---@type table<number, boolean>
M.buffers_to_keep = {}
M.tabpage_section = ""
M.tablineat = vim.fn.has "tablineat"

-- Set vim options and format tabline
function M.enable()
  vim.o.showtabline = 2
  vim.o.hidden = true
  M.create_highlight_groups()
  M.create_clickable_tab_fn()
  vim.o.tabline = [[%!luaeval('require("unclutter.tabline").get_tabline_string()')]]
end

-- Disable tabline
function M.disable()
  vim.o.showtabline = 0
  vim.o.tabline = ""
end

function M.create_highlight_groups()
  vim.api.nvim_set_hl(0, "UnclutterCurrent", { link = "TabLineSel", default = true })
  vim.api.nvim_set_hl(0, "UnclutterVisible", { link = "TabLineFill", default = true })
  vim.api.nvim_set_hl(0, "UnclutterHidden", { link = "TabLine", default = true })
  vim.api.nvim_set_hl(0, "UnclutterFill", { link = "Normal", default = true })
  vim.api.nvim_set_hl(0, "UnclutterTabPage", { link = "Search", default = true })
  vim.api.nvim_set_hl(0, "UnclutterTablineFill", { link = "Normal", default = true })
end

-- Update tabpage section string
-- Copied from https://github.com/echasnovski/mini.tabline/blob/main/lua/mini/tabline.lua
function M.make_tabpage_section()
  local n_tabpages = vim.fn.tabpagenr "$"
  if n_tabpages == 1 then
    M.tabpage_section = ""
    return
  end

  local cur_tabpagenr = vim.fn.tabpagenr()
  M.tabpage_section = (" Tab %s/%s "):format(cur_tabpagenr, n_tabpages)
end

-- Remove a buffer from the list
function M.remove_buffer(bufnr)
  M.buffers_to_keep[bufnr] = nil
end

-- Add a buffer to the list
---@param bufnr number
function M.keep_buffer(bufnr)
  if bufnr == nil then
    return
  end
  M.buffers_to_keep[bufnr] = true
end

-- Toggle a buffer in the buffer list
---@param bufnr number
function M.toggle_buffer(bufnr)
  if M.is_buffer_kept(bufnr) then
    M.remove_buffer(bufnr)
  else
    M.keep_buffer(bufnr)
  end
end

-- Create the function for switching buffers with the mouse
-- Copied from https://github.com/echasnovski/mini.tabline/blob/main/lua/mini/tabline.lua#L185
function M.create_clickable_tab_fn()
  vim.cmd(
    [[function! UnclutterSwitchBuffer(buf_id, clicks, button, mod)
        execute 'buffer' a:buf_id
      endfunction]],
    false
  )
end

-- Is buffer hidden?
---@param bufnr number
---@return boolean
function M.is_buffer_hidden(bufnr)
  return M.buffers_to_keep[bufnr] == nil
end

-- Is buffer shown?
---@param bufnr number
---@return boolean
function M.is_buffer_kept(bufnr)
  return M.buffers_to_keep[bufnr] == true
end

-- Get the highlight group for a buffer
---@param buf number
function M.get_tab_highlight(buf)
  local hl
  if buf == buffer.current() then
    hl = "Current"
  elseif vim.fn.bufwinnr(buf) > 0 then
    hl = "Visible"
  else
    hl = "Hidden"
  end
  return string.format("%%#Unclutter%s#", hl)
end

-- Get the tab's clickable action
---@param buf number
function M.get_tab_func(buf)
  -- Tab's clickable action (if supported)
  if M.tablineat > 0 then
    return string.format("%%%d@UnclutterSwitchBuffer@", buf)
  else
    return ""
  end
end

-- Get the tab's label
---@param buf number
---@return string|nil
function M.get_tab_label(buf)
  local file = buffer.name(buf)
  local type = buffer.type(buf)

  if file == "" and type ~= "nofile" then
    return string.format(" %s ", type)
  end

  local label = vim.fn.fnamemodify(file, ":t")

  if label == nil then
    return nil
  end

  if has_icons then
    local file_extension = vim.fn.fnamemodify(file, ":e")
    local icon = icons.get_icon(label, file_extension, { default = true })
    if label == "" and icon then
      return string.format(" %s ", icon)
    end
    return string.format(" %s %s ", icon, label)
  end

  if label == "" then
    return " • "
  end

  return string.format(" %s ", label)
end

-- Get all buffers to be displayed in the tabline
---@return table<number, number>
function M.get_buffers()
  local buffers = {}
  local all_buffers = buffer.all()

  for _, buf in ipairs(all_buffers) do
    if
      buffer.current() == buf -- keep current buffer
      or M.is_buffer_kept(buf) -- keep buffers that are marked
      or buffer.is_visible(buf) -- keep visible buffers
      or not buffer.is_file(buf) -- keep non-file buffers
      or #buffers < config.clean_after -- keep first n buffers (config)
    then
      table.insert(buffers, buf)
    end
  end

  return buffers
end

-- Get all tabs
---@return table<number, table>
function M.get_buffer_tabs()
  local tabs = {}
  for _, buf in ipairs(M.get_buffers()) do
    local tab = { buf_id = buf }
    tab["hl"] = M.get_tab_highlight(buf)
    tab["func"] = M.get_tab_func(buf)
    tab["label"] = M.get_tab_label(buf)

    if tab["label"] ~= nil then
      table.insert(tabs, tab)
    end
  end
  return tabs
end

-- Get the tabline string
function M.get_tabline_string()
  M.make_tabpage_section()

  local buffer_tabs = {}
  for _, tab in ipairs(M.get_buffer_tabs()) do
    table.insert(buffer_tabs, ("%s%s%s"):format(tab.hl, tab.func, tab.label))
  end

  local buffer_tabline = ("%s%%X%%#UnclutterTablineFill#"):format(table.concat(buffer_tabs, ""))
  local buffers_and_tabs = ("%%#UnclutterTabPage#%s%s"):format(M.tabpage_section, buffer_tabline)

  return buffers_and_tabs
end

-- Navigate to next buffer
function M.next()
  local buffers = M.get_buffers()
  if buffers == nil or #buffers < 2 then
    print "No more buffers"
    return
  end
  local current = buffer.current()
  local next_buffer = nil
  for i, buf in ipairs(buffers) do
    if buf == current then
      if i == #buffers then
        next_buffer = buffers[1]
      else
        next_buffer = buffers[i + 1]
      end
      break
    end
  end

  if next_buffer ~= nil then
    vim.cmd("buffer " .. next_buffer)
  end
end

-- Navigate to previous buffer
function M.prev()
  local buffers = M.get_buffers()
  if buffers == nil or #buffers < 2 then
    print "No more buffers"
    return
  end
  local current = buffer.current()
  local previous_buffer = nil
  for i, buf in ipairs(buffers) do
    if buf == current then
      if i == 1 then
        previous_buffer = buffers[#buffers]
      else
        previous_buffer = buffers[i - 1]
      end
      break
    end
  end

  if previous_buffer ~= nil then
    vim.cmd("buffer " .. previous_buffer)
  end
end

return M
