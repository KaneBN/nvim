vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", function() vim.cmd("Ex") end)

-- Move highlighted lines
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '>-2<CR>gv=gv")

-- Keep cursor in position when copying line below and appeding with a space
vim.keymap.set("n", "J", "mzJ`z")

-- Keep cursor in the middle of the screen when jumping up/down half pages 
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- Keep cursor in the middle of the screen when jumping with search
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Paste yanked word without overwriting copied buffer
vim.keymap.set("x", "<leader>p", "\"_dP")

-- Yank to the system buffer 
vim.keymap.set("n", "<leader>y", "\"+y")
vim.keymap.set("v", "<leader>y", "\"+y")
vim.keymap.set("n", "<leader>Y", "\"+y")

-- Delete to the system buffer
vim.keymap.set("n", "<leader>d", "\"_d")
vim.keymap.set("v", "<leader>d", "\"_d")

-- Remove capital Q from quitting
vim.keymap.set("n", "Q", "<nop>")

vim.keymap.set('', '<leader>pp', ':w | :! sfdx force:source:deploy -p \'%:p\'<CR>')

-- Remap LazyGit command
vim.keymap.set('', '<leader>lg', ':LazyGit<CR>')
