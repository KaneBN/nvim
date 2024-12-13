return {
	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
				cond = vim.fn.executable("cmake") == 1,
			},
		},
		config = function()
			local actions = require("telescope.actions")

			require("telescope").setup({
				defaults = {
					mappings = {
						i = {
							["<C-k>"] = actions.move_selection_previous,
							["<C-j>"] = actions.move_selection_next,
							["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
							["<C-x>"] = actions.delete_buffer,
						},
					},
					file_ignore_patterns = {
						"node_modules",
						"yarn.lock",
						".git",
						".sl",
						"_build",
						".next",
					},
					hidden = true,
				},
				extensions = {
					fzf = {
						fuzzy = true, -- false will only do exact matching
						override_generic_sorter = true,
						override_file_sorter = true,
						case_mode = "smart_case", -- this is default
					},
					file_browser = {
						hidden = true,
					},
				},
			})

			-- Enable telescope fzf native, if installed
			pcall(require("telescope").load_extension, "fzf")
		end,
		keys = {
			-- telescope notify history
			{
				"<leader>nh",
				function()
					require("telescope").extensions.notify.notify({
						results_title = "Notification History",
						prompt_title = "Search Messages",
					})
				end,
				desc = "Notification History",
			},
			-- Telescope resume (last picker)
			{
				"<leader>tr",
				function()
					require("telescope.builtin").resume()
				end,
				desc = "Resume last telescope picker",
			},
			-- Telescope Commands
			{
				"<leader>tc",
				function()
					require("telescope.builtin").commands({ results_title = "Commands Results" })
				end,
				desc = "Telescope Commands",
			},
			-- Telescope find in buffer
			{
				"<leader>fb",
				function()
					require("telescope.builtin").current_buffer_fuzzy_find()
				end,
			},
			-- Telescope show keymaps
			{
				"<leader>tk",
				function()
					require("telescope.builtin").keymaps({ results_title = "Key Maps Results" })
				end,
			},
			-- Telescope help
			{
				"<leader>th",
				function()
					require("telescope.builtin").help_tags({ results_title = "Help Results" })
				end,
			},
			{
				"<leader>ff",
				function()
					require("telescope.builtin").find_files()
				end,
			},
		},
	},
}
