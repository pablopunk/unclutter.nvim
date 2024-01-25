local docgen = require "docgen"

local docs = {}

docs.test = function()
  local input_files = {
    "./lua/unclutter/init.lua", -- force this to be first
  }

  local files = vim.fn.glob("./lua/unclutter/*.lua", true, 1)

  for _, file in ipairs(files) do
    if not file:match "_spec" and not vim.tbl_contains(input_files, file) then
      table.insert(input_files, file)
    end
  end

  local output_file = "./doc/unclutter.txt"
  local output_file_handle = io.open(output_file, "w")
  assert(output_file_handle, "Could not open " .. output_file)

  for _, input_file in ipairs(input_files) do
    docgen.write(input_file, output_file_handle)
  end

  output_file_handle:write " vim:tw=78:ts=8:ft=help:norl:\n"
  output_file_handle:close()
  vim.cmd [[checktime]]
end

docs.test()

return docs
