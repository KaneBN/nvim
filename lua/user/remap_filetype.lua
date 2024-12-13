vim.api.nvim_create_autocmd({'BufRead', 'BufNewFile'}, {
  pattern = 'Query.cls',
  command = 'set ft=sql' -- or whatever ':set filetype' evaluates to in a .ini file 
})
