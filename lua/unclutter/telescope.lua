local buffer = require "unclutter.buffer"
local has_icons, icons = pcall(require, "nvim-web-devicons")

local M = {}

M.open_buffers = function()
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

  pickers
    .new({
      previewer = previewers.vim_buffer_cat.new {}, -- Use buffer content previewer
      prompt_title = "Select Buffer (unclutter.nvim)",
      finder = finders.new_table {
        results = tabline_buffers,
        entry_maker = function(bufnr)
          local full_path = buffer.name(bufnr)
          local path_segments = vim.split(full_path, "/")
          local name = ""
          if #path_segments > 1 then
            name = path_segments[#path_segments - 1] .. "/" .. path_segments[#path_segments]
          else
            name = path_segments[#path_segments]
          end

          local display = name

          if has_icons then
            local file_extension = vim.fn.fnamemodify(name, ":e")
            local icon = icons.get_icon(name, file_extension, { default = true })
            local icon_str = icon and (icon .. " ") or ""
            display = icon_str .. name
          end

          return {
            value = full_path, -- Pass the full path for previewing
            display = display,
            ordinal = full_path,
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
