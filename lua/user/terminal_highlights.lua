-- Terminal highlight configurations
local M = {}

function M.setup()
	-- Define custom highlight groups for terminal borders
	vim.api.nvim_set_hl(0, 'TerminalBorder', { 
		fg = '#87CEEB', -- Light blue
		bold = true 
	})
	
	-- Also create a fallback using more common highlight groups
	vim.api.nvim_create_autocmd("ColorScheme", {
		callback = function()
			vim.api.nvim_set_hl(0, 'TerminalBorder', { 
				fg = '#87CEEB', -- Light blue  
				bold = true
			})
		end,
	})
end

return M