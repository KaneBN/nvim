return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
        vim.o.timeout = true
        vim.o.timeoutlen = 300
    end,
    opts = {
        -- your configuration comes here
        -- or leave it empty to use the default settings
	},
	keys = {
        g = {
            name = "+Git",
            h = {
                name = "+Github",
                c = {
                    name = "+Commits",
                    c = { "<cmd>GHCloseCommit<cr>", "Close" },
                    e = { "<cmd>GHExpandCommit<cr>", "Expand" },
                    o = { "<cmd>GHOpenToCommit<cr>", "Open To" },
                    p = { "<cmd>GHPopOutCommit<cr>", "Pop Out" },
                    z = { "<cmd>GHCollapseCommit<cr>", "Collapse" },
                },
                i = {
                    name = "+Issues",
                    p = { "<cmd>GHPreviewIssue<cr>", "Preview" },
                },
                l = {
                    name = "+Litee",
                    t = { "<cmd>LTPanel<cr>", "Toggle Panel" },
                },
                r = {
                    name = "+Review",
                    b = { "<cmd>GHStartReview<cr>", "Begin" },
                    c = { "<cmd>GHCloseReview<cr>", "Close" },
                    d = { "<cmd>GHDeleteReview<cr>", "Delete" },
                    e = { "<cmd>GHExpandReview<cr>", "Expand" },
                    s = { "<cmd>GHSubmitReview<cr>", "Submit" },
                    z = { "<cmd>GHCollapseReview<cr>", "Collapse" },
                },
                p = {
                    name = "+Pull Request",
                    c = { "<cmd>GHClosePR<cr>", "Close" },
                    d = { "<cmd>GHPRDetails<cr>", "Details" },
                    e = { "<cmd>GHExpandPR<cr>", "Expand" },
                    o = { "<cmd>GHOpenPR<cr>", "Open" },
                    p = { "<cmd>GHPopOutPR<cr>", "PopOut" },
                    r = { "<cmd>GHRefreshPR<cr>", "Refresh" },
                    t = { "<cmd>GHOpenToPR<cr>", "Open To" },
                    z = { "<cmd>GHCollapsePR<cr>", "Collapse" },
                },
                t = {
                    name = "+Threads",
                    c = { "<cmd>GHCreateThread<cr>", "Create" },
                    n = { "<cmd>GHNextThread<cr>", "Next" },
                    t = { "<cmd>GHToggleThread<cr>", "Toggle" },
                },
            },
            { prefix = "<leader>" },
        },
		f = {
			name = "Find",
			g = {
				name = "multigrep",
			},
			t = {
				name = "terminal (cwd)",
			},
			b = {
				name = "current buffer (fuzzy)",
			},
			{ prefix = "<leader>" },
		}
    },
}
