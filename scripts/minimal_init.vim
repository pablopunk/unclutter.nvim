let plenary_path = stdpath('data') . '/lazy/plenary.nvim/'
execute 'set rtp+=' . plenary_path

runtime! plugin/plenary.vim
runtime! plugin/unclutter.lua

