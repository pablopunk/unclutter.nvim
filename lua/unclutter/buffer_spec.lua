local M = require "unclutter.buffer"

local CURRENT_BUFNAME = "test.lua"
local CURRENT_BUFNR = 42
local NO_FILE_BUF = 5

describe("Buffer functions", function()
  before_each(function()
    -- Setting up mocks before each test
    ---@diagnostic disable-next-line: duplicate-set-field
    vim.api.nvim_get_current_buf = function()
      return CURRENT_BUFNR
    end
    ---@diagnostic disable-next-line: duplicate-set-field
    vim.fn.bufnr = function(file_path)
      if file_path == CURRENT_BUFNAME then
        return CURRENT_BUFNR
      end
      return -1
    end
    ---@diagnostic disable-next-line: duplicate-set-field
    vim.api.nvim_buf_get_name = function(buf)
      if buf == CURRENT_BUFNR then
        return CURRENT_BUFNAME
      end
      return ""
    end
    ---@diagnostic disable-next-line: duplicate-set-field
    vim.api.nvim_get_option_value = function(option, opts)
      if option == "buftype" then
        if opts.buf == NO_FILE_BUF then
          return "nofile"
        elseif opts.buf == CURRENT_BUFNR then
          return ""
        end
        return "nofile"
      end
    end
    ---@diagnostic disable-next-line: duplicate-set-field
    vim.fn.win_findbuf = function(buf)
      if buf == CURRENT_BUFNR then
        return { 1, 2 } -- Example buffer is open in two windows
      end
      return {}
    end
    ---@diagnostic disable-next-line: duplicate-set-field
    vim.fn.tabpagebuflist = function()
      return { 3, CURRENT_BUFNR, 7 } -- Example buffers in current tab
    end
    ---@diagnostic disable-next-line: duplicate-set-field
    vim.api.nvim_buf_is_valid = function(buf)
      return buf == CURRENT_BUFNR -- Only CURRENT_BUF is considered valid in this mock
    end
    ---@diagnostic disable-next-line: duplicate-set-field
    vim.api.nvim_buf_is_loaded = function(buf)
      return buf == CURRENT_BUFNR -- Only CURRENT_BUF is considered loaded in this mock
    end
    vim.bo = setmetatable({}, {
      __index = function(_, buf)
        if buf == CURRENT_BUFNR then
          return { buflisted = true }
        end
        return { buflisted = false }
      end,
    })
    ---@diagnostic disable-next-line: duplicate-set-field
    vim.api.nvim_list_bufs = function()
      return { 3, 7 } -- Example of all buffers
    end
  end)

  it("gets the current buffer number", function()
    local buf = M.current()
    assert.is.equal(CURRENT_BUFNR, buf)
  end)

  it("gets the buffer number for a file path", function()
    local buf = M.number(CURRENT_BUFNAME)
    assert.is.equal(CURRENT_BUFNR, buf)
  end)

  it("gets the name of a buffer", function()
    local name = M.name(CURRENT_BUFNR)
    assert.is.equal(CURRENT_BUFNAME, name)
  end)

  it("gets the buffer type", function()
    local buftype = M.type(NO_FILE_BUF)
    assert.is.equal("nofile", buftype)
  end)

  it("checks if buffer is a file", function()
    local isFile = M.is_file(CURRENT_BUFNR)
    assert.is_true(isFile)
  end)

  it("gets the number of windows a buffer is open in", function()
    local windows = M.windows(CURRENT_BUFNR)
    assert.is.equal(2, windows)
  end)

  it("checks if buffer is visible in current tab", function()
    local isVisible = M.is_visible(CURRENT_BUFNR)
    assert.is_true(isVisible)
  end)

  it("checks if buffer is valid", function()
    local isValid = M.is_valid(CURRENT_BUFNR)
    assert.is_true(isValid)
  end)

  it("checks if buffer is loaded", function()
    local isLoaded = M.is_loaded(CURRENT_BUFNR)
    assert.is_true(isLoaded)
  end)

  it("checks if a buffer is listed", function()
    local isListed = M.listed(CURRENT_BUFNR)
    assert.is_true(isListed)
  end)

  it("returns the current buffer in .all()", function()
    local all = M.all()
    local current = M.current()
    assert.is_true(vim.tbl_contains(all, current))
  end)
end)
