---@class unclutter.config
local defaults = {
  clean_after = 3,
  tabline = true,
}

---@class unclutter.config
local M = defaults

--- Set config values
---@param opts unclutter.config
function M.set(opts)
  opts = opts or defaults

  if opts.clean_after ~= nil then
    M.clean_after = opts.clean_after
  end

  if opts.tabline ~= nil then
    M.tabline = opts.tabline
  end

  return opts
end

return M
