local defaults = {
  clean_after = 3,
  tabline = true,
}

---@class unclutter.config
---@field clean_after number
---@field tabline boolean
local config = defaults

--- Set config values
---@param opts unclutter.config
function config.set(opts)
  opts = opts or defaults

  if opts.clean_after ~= nil then
    config.clean_after = opts.clean_after
  end

  if opts.tabline ~= nil then
    config.tabline = opts.tabline
  end

  return opts
end

return config
