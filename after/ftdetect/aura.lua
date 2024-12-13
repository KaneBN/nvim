-- Properly set the file type for aura components files
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = "*.cmp, *.design, *.auradoc",
	desc = "Detect and set the proper file type for aura component files",
	callback = function()
		vim.cmd(":set filetype=html")
	end,
})
