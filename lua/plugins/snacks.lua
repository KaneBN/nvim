return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	---@type snacks.Config
	opts = {
		terminal = {
			border = "rounded",
		},
		styles = {
			float = {
				backdrop = 100,
				border = "rounded",
			},
		},
		bigfile = { enabled = true },
		dashboard = { enabled = true },
		notifier = {
			enabled = true,
			timeout = 3000,
		},
		quickfile = { enabled = true },
		statuscolumn = { enabled = true },
		words = { enabled = true },
		styles = {
			notification = {
				wo = { wrap = true } -- Wrap notifications
			}
		},
		picker = {}
	},
	keys = {
		{ "<leader>,",  function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },
		{ "<leader>S",  function() Snacks.scratch.select() end, desc = "Select Scratch Buffer" },
		{ "<leader>n",  function() Snacks.notifier.show_history() end, desc = "Notification History" },
		{ "<leader>bd", function() Snacks.bufdelete() end, desc = "Delete Buffer" },
		{ "<leader>cR", function() Snacks.rename.rename_file() end, desc = "Rename File" },
		{ "<leader>gB", function() Snacks.gitbrowse() end, desc = "Git Browse" },
		{ "<leader>gb", function() Snacks.git.blame_line() end, desc = "Git Blame Line" },
		{ "<leader>gf", function() Snacks.lazygit.log_file() end, desc = "Lazygit Current File History" },
		{ "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },
		{ "<leader>gl", function() Snacks.lazygit.log() end, desc = "Lazygit Log (cwd)" },
		{ "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
		{ "<c-/>",      function() Snacks.terminal() end, desc = "Toggle Terminal" },
		{ "<c-_>",      function() Snacks.terminal() end, desc = "which_key_ignore" },
		{ "]]",         function() Snacks.words.jump(vim.v.count1) end, desc = "Next Reference", mode = { "n", "t" } },
		{ "[[",         function() Snacks.words.jump(-vim.v.count1) end, desc = "Prev Reference", mode = { "n", "t" } },
		-- Snacks picker
		{ "<leader>bb", function() Snacks.picker.buffers() end, desc = "Buffers" },
		{ "<leader><space>", function() Snacks.picker.grep() end, desc = "Grep" },
		-- find
		{ "<leader>ff", function() Snacks.picker.files() end, desc = "Find Files" },
		{ "<leader>fr", function() Snacks.picker.recent() end, desc = "Recent" },
		-- git
		{ "<leader>gc", function() Snacks.picker.git_log() end, desc = "Git Log" },
		{ "<leader>gs", function() Snacks.picker.git_status() end, desc = "Git Status" },
		-- Grep
		{ "<leader>bl", function() Snacks.picker.lines() end, desc = "Buffer Lines" },
		{ "<leader>sB", function() Snacks.picker.grep_buffers() end, desc = "Grep Open Buffers" },
		{ "<leader>sg", function() Snacks.picker.grep() end, desc = "Grep" },
		{ "<leader>sw", function() Snacks.picker.grep_word() end, desc = "Visual selection or word", mode = { "n", "x" } },
		-- search
		{ "<leader>sC", function() Snacks.picker.commands() end, desc = "Commands" },
		-- LSP
		{ "gd", function() Snacks.picker.lsp_definitions() end, desc = "Goto Definition" },
		{ "gr", function() Snacks.picker.lsp_references() end, nowait = true, desc = "References" },
		{ "gy", function() Snacks.picker.lsp_type_definitions() end, desc = "Goto T[y]pe Definition" },
		{ "<leader>ss", function() Snacks.picker.lsp_symbols() end, desc = "LSP Symbols" },
		{ "<leader>gi", function() Snacks.picker.gh_issue() end, desc = "GitHub Issues (open)" },
		{ "<leader>gI", function() Snacks.picker.gh_issue({ state = "all" }) end, desc = "GitHub Issues (all)" },
		{ "<leader>gp", function() Snacks.picker.gh_pr() end, desc = "GitHub Pull Requests (open)" },
		{ "<leader>gP", function() Snacks.picker.gh_pr({ state = "all" }) end, desc = "GitHub Pull Requests (all)" },
		{
		"<leader>N",
		desc = "Neovim News",
		function()
			Snacks.win({
			file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
			width = 0.6,
			height = 0.6,
			wo = {
				spell = false,
				wrap = false,
				signcolumn = "yes",
				statuscolumn = " ",
				conceallevel = 3,
			},
			})
		end,
		}
	},
	init = function()
		vim.api.nvim_create_autocmd("User", {
		pattern = "VeryLazy",
		callback = function()
			-- Setup some globals for debugging (lazy-loaded)
			_G.dd = function(...)
				Snacks.debug.inspect(...)
			end
			_G.bt = function()
				Snacks.debug.backtrace()
			end

			vim.print = _G.dd -- Override print to use snacks for `:=` command

			-- Create some toggle mappings
			Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
			Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
			Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
			Snacks.toggle.diagnostics():map("<leader>ud")
			Snacks.toggle.line_number():map("<leader>ul")
			Snacks.toggle.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 }):map("<leader>uc")
			Snacks.toggle.treesitter():map("<leader>uT")
			Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
			Snacks.toggle.inlay_hints():map("<leader>uh")
		end,
		})
	end,
}
