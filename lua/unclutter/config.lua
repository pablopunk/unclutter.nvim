---@class Config
local defaults = {
  clean_after = 3,
  tabline = true,
}

---@class Config
local M = defaults

---@param opts Config
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
