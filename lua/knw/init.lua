require("knw.remap")
require("knw.set")

-- Set filetypes for Apex, Triggers & Aura Components
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile"},
   {pattern = {"*.cls", "*.trigger"}, command = "set filetype=java"}
)

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile"},
   {pattern = {"*.cmp", "*.auradoc", "*.design"}, command = "set filetype=html"}
)

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile"},
   {pattern = {"*.cmp", "*.auradoc", "*.design"}, command = "set filetype=html"}
)


