local M = require "unclutter.tabline"

describe("Tabpage section", function()
  it("creates tabpage section for multiple tabpages", function()
    -- Mock vim.fn.tabpagenr
    ---@diagnostic disable-next-line: duplicate-set-field
    vim.fn.tabpagenr = function(arg)
      if arg == "$" then
        return 3
      end -- total tabpages
      return 2 -- current tabpage
    end

    M.make_tabpage_section()
    assert.are.equal(" Tab 2/3 ", M.tabpage_section)
  end)

  it("creates no tabpage section for a single tabpage", function()
    -- Mock vim.fn.tabpagenr
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
