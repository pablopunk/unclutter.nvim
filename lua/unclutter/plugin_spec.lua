local M = require "unclutter.plugin"
local config = require "unclutter.config"
local mock = require "luassert.mock"

local autocmds, buffer, tabline

describe("Unclutter", function()
  before_each(function()
    M.enabled = false
    M.buf_just_left = nil

    autocmds = mock(require "unclutter.autocmds", true)
    buffer = mock(require "unclutter.buffer", true)
    tabline = mock(require "unclutter.tabline", true)

    config.set {
      clean_after = 3,
      tabline = true,
    }
  end)

  after_each(function()
    mock.clear(autocmds)
    mock.clear(buffer)
    mock.clear(tabline)
  end)

  describe("enable", function()
    it("enables the plugin with tabline enabled", function()
      M.enable { tabline = true }
      assert.is_true(M.enabled)
      assert.stub(tabline.enable).was_called()
      assert.stub(tabline.disable).was_not_called()
    end)

    it("enables the plugin with tabline disabled", function()
      M.enable { tabline = false }
      assert.is_true(M.enabled)
      assert.stub(tabline.enable).was_not_called()
      assert.stub(tabline.disable).was_called()
    end)

    it("enables the plugin with default settings when no options are provided", function()
      M.enable {}
      assert.is_true(M.enabled)
      assert.are.equal(3, config.clean_after) -- Default value
      assert.are.equal(true, config.tabline) -- Default value
    end)

    it("partially updates settings when partial options are provided", function()
      M.enable { tabline = false } -- Only providing tabline option
      assert.is_true(M.enabled)
      assert.are.equal(3, config.clean_after) -- Default value
      assert.are.equal(false, config.tabline) -- Updated value
    end)
  end)

  describe("disable", function()
    it("disables the plugin", function()
      M.enabled = true
      M.disable()
      assert.is_false(M.enabled)
      assert.stub(autocmds.remove_augroup).was_called()
      assert.stub(tabline.disable).was_called()
    end)
  end)

  describe("buffer_should_be_hidden_on_leave", function()
    it("checks if buffer should be hidden on leave", function()
      buffer.current.returns(2)
      buffer.is_file.returns(true)
      buffer.is_visible.returns(false)
      buffer.windows.returns(0)
      tabline.is_buffer_kept.returns(false)

      local result = M.buffer_should_be_hidden_on_leave(1)
      assert.is_true(result)
    end)
    it("does not hide the buffer if it is kept", function()
      buffer.current.returns(2)
      buffer.is_file.returns(true)
      buffer.is_visible.returns(false)
      buffer.windows.returns(0)
      tabline.is_buffer_kept.returns(true) -- Buffer is kept

      local result = M.buffer_should_be_hidden_on_leave(1)
      assert.is_false(result)
    end)
  end)

  describe("keep_all_buffers", function()
    it("keeps all buffers", function()
      buffer.all.returns { 1, 2, 3 }
      M.keep_all_buffers()
      assert.stub(tabline.keep_buffer).was_called(3)
    end)
    it("does nothing when there are no buffers", function()
      buffer.all.returns {}
      M.keep_all_buffers()
      assert.stub(tabline.keep_buffer).was_not_called()
    end)
  end)
end)
