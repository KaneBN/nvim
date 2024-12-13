-- Properly set the file type for apex files
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = "*.cls, *.trigger, *.apex",
	desc = "Detect and set the proper file type for apex interface files",
	callback = function()
		vim.cmd(":set filetype=apex")
	end,
})
