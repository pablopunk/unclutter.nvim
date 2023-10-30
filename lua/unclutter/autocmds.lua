local M = {}
local augroup = vim.api.nvim_create_augroup("Unclutter", {})

M.on_buf_leave = function(callback)
  vim.api.nvim_create_autocmd("BufLeave", {
    group = augroup,
    pattern = "*",
    callback = callback,
  })
end

M.on_buf_delete = function(callback)
  vim.api.nvim_create_autocmd("BufDelete", {
    group = augroup,
    pattern = "*",
    callback = callback,
  })
end

M.on_buf_enter = function(callback)
  vim.api.nvim_create_autocmd("BufEnter", {
    group = augroup,
    pattern = "*",
    callback = callback,
  })
end

M.on_buf_write_post = function(callback)
  vim.api.nvim_create_autocmd("BufWritePost", {
    group = augroup,
    pattern = "*",
    callback = callback,
  })
end

M.on_vim_enter = function(callback)
  vim.api.nvim_create_autocmd("VimEnter", {
    group = augroup,
    pattern = "*",
    callback = callback,
  })
end

M.on_insert_enter = function(callback)
  vim.api.nvim_create_autocmd("InsertEnter", {
    group = augroup,
    pattern = "*",
    callback = callback,
  })
end

M.on_buf_modified_set = function(callback)
  vim.api.nvim_create_autocmd("BufModifiedSet", {
    group = augroup,
    pattern = "*",
    callback = callback,
  })
end

M.on_win_enter = function(callback)
  vim.api.nvim_create_autocmd("WinEnter", {
    group = augroup,
    pattern = "*",
    callback = callback,
  })
end

return M
