---@class unclutter.autocmds
local autocmds = {}
local augroup_name = "Unclutter"
local augroup = vim.api.nvim_create_augroup(augroup_name, {})

-- Remove created augroup
autocmds.remove_augroup = function()
  pcall(vim.api.nvim_del_augroup_by_name, augroup_name)
end

autocmds.on_buf_leave = function(callback)
  vim.api.nvim_create_autocmd("BufLeave", {
    group = augroup,
    pattern = "*",
    callback = callback,
  })
end

autocmds.on_buf_delete = function(callback)
  vim.api.nvim_create_autocmd("BufDelete", {
    group = augroup,
    pattern = "*",
    callback = callback,
  })
end

autocmds.on_buf_enter = function(callback)
  vim.api.nvim_create_autocmd("BufEnter", {
    group = augroup,
    pattern = "*",
    callback = callback,
  })
end

autocmds.on_buf_write_post = function(callback)
  vim.api.nvim_create_autocmd("BufWritePost", {
    group = augroup,
    pattern = "*",
    callback = callback,
  })
end

autocmds.on_vim_enter = function(callback)
  vim.api.nvim_create_autocmd("VimEnter", {
    group = augroup,
    pattern = "*",
    callback = callback,
  })
end

autocmds.on_insert_enter = function(callback)
  vim.api.nvim_create_autocmd("InsertEnter", {
    group = augroup,
    pattern = "*",
    callback = callback,
  })
end

autocmds.on_buf_modified_set = function(callback)
  vim.api.nvim_create_autocmd("BufModifiedSet", {
    group = augroup,
    pattern = "*",
    callback = callback,
  })
end

autocmds.on_win_enter = function(callback)
  vim.api.nvim_create_autocmd("WinEnter", {
    group = augroup,
    pattern = "*",
    callback = callback,
  })
end

autocmds.on_win_new = function(callback)
  vim.api.nvim_create_autocmd("WinNew", {
    group = augroup,
    pattern = "*",
    callback = callback,
  })
end

return autocmds
