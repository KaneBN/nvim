-- Helper function to check if a buffer with the given name exists
local find_existing_buffer = function(buf_name)
	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(bufnr) then
			local current_buf_name = vim.api.nvim_buf_get_name(bufnr)
			if current_buf_name == buf_name then
				return bufnr
			end
		end
	end
	print("No existing buffer found")
	return nil
end

-- AutoRun for split buffer messaging
local attach_to_buffer = function(output_bufnr, pattern, command, file_name)
	local augroup = vim.api.nvim_create_augroup("command_group", { clear = false })
	vim.api.nvim_create_autocmd({ "BufWritePost" }, {
		group = augroup,
		pattern = pattern,
		callback = function()
			-- Define a buffer name
			local current_file_path = vim.api.nvim_buf_get_name(0) -- Dynamically grab current file path
			local buf_name = current_file_path .. " Output Buffer" -- Use current file path for buffer name

			-- Check if the buffer already exists
			local existing_buf = find_existing_buffer(buf_name)
			local output_buf

			if existing_buf == nil then
				-- Create a new split window and buffer
				vim.cmd.new()
				vim.cmd.wincmd("L")
				output_buf = vim.api.nvim_get_current_buf()

				-- Set a name to the new buffer only if it's new
				local success, err = pcall(function()
					vim.api.nvim_buf_set_name(output_buf, buf_name)
				end)
				if not success then
					print("Error setting buffer name: " .. err)
				else
					print("New buffer created with ID: " .. output_buf)
				end
			else
				-- If buffer exists, use it
				output_buf = existing_buf
			end

			local message = "output of" .. file_name .. " :"

			-- Clear existing lines in the buffer before adding new output
			vim.api.nvim_buf_set_lines(output_buf, 0, -1, false, { message })

			-- Start job and set output to the buffer
			vim.fn.jobstart(command, {
				stdout_buffered = true,
				on_stdout = function(_, data)
					vim.api.nvim_buf_set_lines(output_buf, -1, -1, false, data)
				end,
				on_stderr = function(_, data)
					vim.api.nvim_buf_set_lines(output_buf, -1, -1, false, data)
				end,
			})

		end,
	})
	return vim.api.nvim_get_current_buf()
end

vim.api.nvim_create_user_command("AutoRun", function()
	local file_name = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
	print("Autorun starting on " .. file_name .. "...")

	-- Get the current buffer ID (the original buffer)
	local current_buf = vim.api.nvim_get_current_buf()

	-- Use the same augroup across autocmds
	local augroup = vim.api.nvim_create_augroup("command_group", { clear = false })

	-- Automatically clean up the autocommand when the original buffer is deleted
	vim.api.nvim_create_autocmd("BufDelete", {
		group = augroup,
		buffer = current_buf,  -- Attach this autocmd to the original buffer
		callback = function()
			print("Original buffer deleted, cleaning up AutoRun...")
			-- Optionally, clear the augroup or perform additional cleanup here
			vim.api.nvim_del_augroup_by_name("command_group")
		end,
	})

	attach_to_buffer(0, "*.js", "bun " .. file_name, file_name)
end, {})
