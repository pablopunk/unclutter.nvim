local buffer = require "unclutter.buffer"
local config = require "unclutter.config"

local has_icons, icons -- init later (when needed)

---@class unclutter.tabline
local tabline = {}

---@type table<number, boolean>
tabline.buffers_to_keep = {}
tabline.tabpage_section = ""
tabline.tablineat = vim.fn.has "tablineat"

-- We still need to allow hidden buffers even if we don't show the tabline
-- Cause we might wanna use the telescope plugin to switch unclutter buffers
vim.o.hidden = true

--- Set vim options and format tabline
function tabline.enable()
  has_icons, icons = pcall(require, "nvim-web-devicons")
  vim.o.showtabline = 2
  tabline.create_highlight_groups()
  tabline.create_clickable_tab_fn()
  vim.o.tabline = [[%!luaeval('require("unclutter.tabline").get_tabline_string()')]]
end

--- Disable tabline
function tabline.disable()
  vim.o.showtabline = 0
  vim.o.tabline = ""
end

function tabline.create_highlight_groups()
  vim.api.nvim_set_hl(0, "UnclutterCurrent", { link = "TabLineSel", default = true })
  vim.api.nvim_set_hl(0, "UnclutterVisible", { link = "TabLineFill", default = true })
  vim.api.nvim_set_hl(0, "UnclutterHidden", { link = "TabLine", default = true })
  vim.api.nvim_set_hl(0, "UnclutterFill", { link = "Normal", default = true })
  vim.api.nvim_set_hl(0, "UnclutterTabPage", { link = "Search", default = true })
  vim.api.nvim_set_hl(0, "UnclutterTablineFill", { link = "Normal", default = true })
end

--- Update tabpage section string
--- Copied from https://github.com/echasnovski/mini.tabline/blob/main/lua/mini/tabline.lua
function tabline.make_tabpage_section()
  local n_tabpages = vim.fn.tabpagenr "$"
  if n_tabpages == 1 then
    tabline.tabpage_section = ""
    return
  end

  local cur_tabpagenr = vim.fn.tabpagenr()
  tabline.tabpage_section = (" Tab %s/%s "):format(cur_tabpagenr, n_tabpages)
end

--- Remove a buffer from the list
---@param bufnr number
function tabline.remove_buffer(bufnr)
  tabline.buffers_to_keep[bufnr] = nil
end

--- Add a buffer to the list
---@param bufnr number
function tabline.keep_buffer(bufnr)
  if bufnr == nil then
    return
  end
  tabline.buffers_to_keep[bufnr] = true
end

--- Toggle a buffer in the buffer list
---@param bufnr number
function tabline.toggle_buffer(bufnr)
  if tabline.is_buffer_kept(bufnr) then
    tabline.remove_buffer(bufnr)
  else
    tabline.keep_buffer(bufnr)
  end
end

--- Create the function for switching buffers with the mouse
--- Copied from https://github.com/echasnovski/mini.tabline/blob/main/lua/mini/tabline.lua#L185
function tabline.create_clickable_tab_fn()
  vim.cmd(
    [[function! UnclutterSwitchBuffer(buf_id, clicks, button, mod)
        execute 'buffer' a:buf_id
      endfunction]],
    false
  )
end

--- Is buffer hidden?
---@param bufnr number
---@return boolean
function tabline.is_buffer_hidden(bufnr)
  return tabline.buffers_to_keep[bufnr] == nil
end

--- Is buffer shown?
---@param bufnr number
---@return boolean
function tabline.is_buffer_kept(bufnr)
  return tabline.buffers_to_keep[bufnr] == true
end

--- Get the highlight group for a buffer
---@param buf number
function tabline.get_tab_highlight(buf)
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

--- Get the tab's clickable action
---@param buf number
function tabline.get_tab_func(buf)
  ---@type string
  local func
  --- Tab's clickable action (if supported)
  if tabline.tablineat > 0 then
    func = string.format("%%%d@UnclutterSwitchBuffer@", buf)
  else
    func = ""
  end
  return func
end

--- Get the tab's label
---@param buf number
---@return string|nil
function tabline.get_tab_label(buf)
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

--- Get all buffers to be displayed in the tabline
---@param hide_current boolean
---@return table<number, number>
function tabline.list(hide_current)
  hide_current = hide_current or false
  local buffers = {}
  local all_buffers = buffer.all()
  local current_buffer = buffer.current()

  for _, buf in ipairs(all_buffers) do
    local is_current_buf = buf == current_buffer
    local should_keep = is_current_buf -- keep current buffer
      or tabline.is_buffer_kept(buf) -- keep buffers that are marked
      or buffer.is_visible(buf) -- keep visible buffers
      or not buffer.is_file(buf) -- keep non-file buffers
      or #buffers < config.clean_after -- keep first n buffers (config)

    if should_keep then
      if not is_current_buf or not hide_current then
        table.insert(buffers, buf)
      end
    end
  end

  return buffers
end

--- Get all tabs
---@return table<number, table>
function tabline.get_buffer_tabs()
  local tabs = {}
  for _, buf in ipairs(tabline.list()) do
    local tab = { buf_id = buf }
    tab["hl"] = tabline.get_tab_highlight(buf)
    tab["func"] = tabline.get_tab_func(buf)
    tab["label"] = tabline.get_tab_label(buf)

    if tab["label"] ~= nil then
      table.insert(tabs, tab)
    end
  end
  return tabs
end

--- Get the tabline string
function tabline.get_tabline_string()
  tabline.make_tabpage_section()

  local buffer_tabs = {}
  for _, tab in ipairs(tabline.get_buffer_tabs()) do
    table.insert(buffer_tabs, ("%s%s%s"):format(tab.hl, tab.func, tab.label))
  end

  local buffer_tabline = ("%s%%X%%#UnclutterTablineFill#"):format(table.concat(buffer_tabs, ""))
  local buffers_and_tabs = ("%%#UnclutterTabPage#%s%s"):format(tabline.tabpage_section, buffer_tabline)

  return buffers_and_tabs
end

--- Navigate to next buffer
function tabline.next()
  local buffers = tabline.list()
  if buffers == nil or #buffers < 2 then
    -- print "No more buffers"
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

--- Navigate to previous buffer
function tabline.prev()
  local buffers = tabline.list()
  if buffers == nil or #buffers < 2 then
    -- print "No more buffers"
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

return tabline
