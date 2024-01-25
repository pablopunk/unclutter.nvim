local plugin = require "unclutter.plugin"

---@class unclutter
local unclutter = {}

--- Setup function (optional)
---@param opts unclutter.config
function unclutter.setup(opts)
  plugin.enable(opts)
end

return unclutter
