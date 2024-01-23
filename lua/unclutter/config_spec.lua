local M = require "unclutter.config"

describe("Config module", function()
  before_each(function()
    -- Reset config to default values before each test
    M.set {
      clean_after = 3,
      tabline = true,
    }
  end)

  it("sets configuration values", function()
    local newConfig = {
      clean_after = 5,
      tabline = false,
    }
    M.set(newConfig)

    assert.is.equal(5, M.clean_after)
    assert.is_false(M.tabline)
  end)

  it("handles nil options by keeping default values", function()
    ---@diagnostic disable-next-line: param-type-mismatch
    M.set(nil)

    assert.is.equal(3, M.clean_after)
    assert.is_true(M.tabline)
  end)

  it("only updates provided fields", function()
    M.set { clean_after = 7 }

    assert.is.equal(7, M.clean_after)
    assert.is_true(M.tabline) -- should remain unchanged
  end)
end)
