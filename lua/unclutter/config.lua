---@class Config
---@field hijack_jumplist boolean
local M = {
  hijack_jumplist = true,
}

---@class SetupOpts
---@field hijack_jumplist boolean|nil `<c-o>` will jump to the previous file even if it was closed by Unclutter

---@param opts SetupOpts
M.init = function(opts)
  if opts == nil then
    opts = {}
  end

  if opts.hijack_jumplist ~= nil then
    M.hijack_jumplist = opts.hijack_jumplist
  end
end

return M
