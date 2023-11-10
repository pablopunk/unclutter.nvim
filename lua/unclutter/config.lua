---@class Config
local M = {
  clean_after = 3,
}

function M.set(opts)
  if opts ~= nil then
    if type(opts.clean_after) == "number" then
      M.clean_after = opts.clean_after
    end
  end
end

return M
