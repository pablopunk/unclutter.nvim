local M = require "unclutter.tabline"

describe("Tabpage section", function()
  before_each(function()
    -- Mock vim.fn.tabpagenr
    ---@diagnostic disable-next-line: duplicate-set-field
    vim.fn.tabpagenr = function(arg)
      if arg == "$" then
        return 3 -- total tabpages for the first test, 1 for the second
      end
      return 2 -- current tabpage for the first test, 1 for the second
    end
  end)

  it("creates tabpage section for multiple tabpages", function()
    M.make_tabpage_section()
    assert.are.equal(" Tab 2/3 ", M.tabpage_section)
  end)

  it("creates no tabpage section for a single tabpage", function()
    -- Change the mock for a single tabpage scenario
    ---@diagnostic disable-next-line: duplicate-set-field
    vim.fn.tabpagenr = function(arg)
      if arg == "$" then
        return 1
      end
      return 1
    end

    M.make_tabpage_section()
    assert.are.equal("", M.tabpage_section)
  end)
end)

describe("Buffer management", function()
  before_each(function()
    M.buffers_to_keep = {}
  end)

  it("keeps a buffer", function()
    M.keep_buffer(1)
    assert.is_true(M.is_buffer_kept(1))
  end)

  it("removes a buffer", function()
    M.keep_buffer(1)
    M.remove_buffer(1)
    assert.is_false(M.is_buffer_kept(1))
  end)

  it("toggles a buffer", function()
    M.toggle_buffer(1)
    assert.is_true(M.is_buffer_kept(1))
    M.toggle_buffer(1)
    assert.is_false(M.is_buffer_kept(1))
  end)
end)
