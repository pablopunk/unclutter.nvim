let plugins_path = stdpath('data') . '/lazy'

set rtp+=.
" for tests
execute 'set rtp+=' . plugins_path . '/plenary.nvim/'
" for docs generation
execute 'set rtp+=' . plugins_path . '/tree-sitter-lua/'


runtime! plugin/plenary.vim
runtime! plugin/ts_lua.vim
runtime! plugin/unclutter.lua
