local buffer = require "unclutter.buffer"
local has_icons, icons = pcall(require, "nvim-web-devicons")

local M = {}

---@param full_path string
---@param type string -- "compact" | "cwd" | "filename"
---@return string
local function format(full_path, type)
  local formatted = ""

  if type == "compact" then
    local path_segments = vim.split(full_path, "/")
    if #path_segments > 1 then
      formatted = path_segments[#path_segments - 1] .. "/" .. path_segments[#path_segments]
    else
      formatted = path_segments[#path_segments]
    end
  end

  if type == "cwd" then
    formatted = vim.fn.fnamemodify(full_path, ":~:.") or full_path
  end

  if type == "filename" then
    formatted = vim.fn.fnamemodify(full_path, ":t") or full_path
  end

  return formatted
end

M.open_buffers = function(opts)
  opts = opts or {}
  opts = {
    format = opts.format or "compact",
  }

  if not pcall(require, "telescope") then
    print "You need to install telescope.nvim if you want to use this integration"
    return
  end

  local tabline_buffers = require("unclutter").list()

  -- Sort the buffers by last used
  table.sort(tabline_buffers, function(a, b)
    return vim.fn.getbufinfo(a)[1].lastused > vim.fn.getbufinfo(b)[1].lastused
  end)

  local pickers = require "telescope.pickers"
  local finders = require "telescope.finders"
  local actions = require "telescope.actions"
  local previewers = require "telescope.previewers"
  local entry_display = require "telescope.pickers.entry_display"

  pickers
    .new({
      previewer = previewers.vim_buffer_cat.new {}, -- Use buffer content previewer
      prompt_title = "unclutter.nvim buffers",
      finder = finders.new_table {
        results = tabline_buffers,
        entry_maker = function(bufnr)
          local full_path = buffer.name(bufnr)
          local display = format(full_path, opts.format)

          if has_icons then
            local file_extension = vim.fn.fnamemodify(full_path, ":e")
            local icon, icon_highlight = icons.get_icon(full_path, file_extension, { default = true })
            icon = icon and (icon .. " ") or ""

            local displayer = entry_display.create {
              separator = "",
              items = {
                { width = 2 },
                { remaining = true },
              },
            }
            local make_display = function()
              return displayer {
                { icon, icon_highlight },
                display,
              }
            end

            return {
              value = full_path,
              ordinal = full_path,
              display = make_display,
              filename = full_path,
            }
          end

          return {
            value = full_path,
            display = display,
            ordinal = full_path,
            filename = full_path,
          }
        end,
      },
      sorter = require("telescope.config").values.generic_sorter {},
      attach_mappings = function(_, map)
        map("i", "<CR>", function(bufnr)
          actions.close(bufnr)
          vim.api.nvim_set_current_buf(bufnr)
        end)
        return true
      end,
      layout_strategy = "horizontal", -- Set layout strategy to horizontal
      layout_config = {
        width = 0.8, -- Set the width of the Telescope window (1 = 100% of the screen)
        height = 0.6, -- Set the height of the Telescope window (1 = 100% of the screen)
        preview_width = 0.5, -- Set the width of the preview (0.5 = 50% of Telescope window)
      },
    })
    :find()
end

return M
