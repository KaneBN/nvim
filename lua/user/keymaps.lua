local nnoremap = require("user.keymap_utils").nnoremap
local vnoremap = require("user.keymap_utils").vnoremap
local inoremap = require("user.keymap_utils").inoremap
local tnoremap = require("user.keymap_utils").tnoremap
local xnoremap = require("user.keymap_utils").xnoremap
local harpoon_ui = require("harpoon.ui")
local harpoon_mark = require("harpoon.mark")
local illuminate = require("illuminate")
local utils = require("user.utils")
local terminal = require("user.terminal")

local M = {}

local function map(mode, lhs, rhs, opts)
	vim.keymap.set(mode, lhs, rhs, opts)
end

-- lazyterm
map("n", "<leader>ft", function()
	terminal.open()
end, { desc = "Terminal (cwd)" })

map("n", "<c-_>", function()
	terminal.open()
end, { desc = "which_key_ignore" })

-- terminal mappings
map("t", "<esc><esc>", "<c-\\><c-n>", { desc = "Enter Normal Mode" })
map("t", "<c-_>", "<cmd>close<cr>", { desc = "which_key_ignore" })
-- Window navigation from terminal
map("t", "<C-h>", [[<Cmd>wincmd h<CR>]])
map("t", "<C-j>", [[<Cmd>wincmd j<CR>]])
map("t", "<C-k>", [[<Cmd>wincmd k<CR>]])
map("t", "<C-l>", [[<Cmd>wincmd l<CR>]])

map("n", "<C-h>", [[<Cmd>wincmd h<CR>]])
map("n", "<C-j>", [[<Cmd>wincmd j<CR>]])
map("n", "<C-k>", [[<Cmd>wincmd k<CR>]])
map("n", "<C-l>", [[<Cmd>wincmd l<CR>]])

-- lazygit
map("n", "<leader>gg", function()
	terminal({ "lazygit" }, { esc_esc = false, ctrl_hjkl = false })
end, { desc = "Lazygit (cwd)" })

-- Press gx to open the link under the cursor
map("n", "gx", ":sil !open <cWORD><cr>", { silent = true })

-- FML!
map("n", "<leader>gf", "<cmd>CellularAutomaton make_it_rain<CR>")

-- Telescope
map("n", "<leader>sf", function()
	require("telescope.builtin").find_files({ hidden = true })
end, { desc = "[S]earch [F]iles" })

-- SalesForce keybinds
map(
	"n",
	"<leader>dd",
	"<C-w>s<C-w>j10<C-w>-:term sfdx force:source:deploy -p '%' -l NoTestRun -w 5<CR>",
	{ desc = "Deploy source to Org (SFDX)" }
)

-- map(
-- 	"n",
-- 	"<leader>dd",
-- 	"<C-w>s<C-w>j10<C-w>-:term sf project deploy start -c <CR>",
-- 	{ desc = "Deploy source to Org (SFDX)" }
-- )

map(
	"n",
	"<leader>]lt",
	":tabnew | set ft=log | /tmp/apexlogs.log<CR><C-w>s<C-w>j:term sf apex tail log --color <bar> tee /tmp/apexlogs.log<C-left><C-left><C-left>",
	{ desc = "Enable tail logging" }
)

map(
	"n",
	"<leader>ll",
	":enew | set ft=log | read !sf apex list log <CR> | :set filetype=log<CR> :7 <CR> | :lua require('keybinder.custom').set_hotkeys()<CR>",
	{ desc = "List Active Debug Logs for authenticated org" }
)

map(
	"n",
	"<leader>lg",
	'0/07L<CR>:nohlsearch<CR>yiw :enew | set ft=log | read !sf apex log get -i <C-r>"<CR> :2<CR>',
	{ desc = "Get Debug Log for selected line" }
)

map(
	"n",
	"<leader>pp",
	"<C-w>s<C-w>j10<C-w>-:term sf community publish --name 'staff'<CR>",
	{ desc = "Publish BN Community" }
)

map("n", "<leader>dc", ":bd<CR>", { desc = "Delete buffer" })
map("n", "<leader>sl", ":set filetype=log<CR>", { desc = "Set log filetype" })

map(
	"n",
	"<leader>ta",
	"<C-w>s<C-w>j10<C-w>-:term sfdx apex:run:test -c -r human -w 5 -n '%:t:r'<CR>",
	{ desc = "Run Apex test on current file" }
)

map(
	"n",
	"<leader>td",
	"<C-w>s<C-w>j10<C-w>-:term sfdx apex:run:test -c -v -r human -w 5 -d /tmp/coverage -n '%:t:r'<CR>",
	{ desc = "Run Apex test with detailed coverage on current file" }
)

map("n", "<leader>oc", ":tabnew /tmp/coverage<CR>", { desc = "Open coverage in new tab" })

-- Run just the specific test you are in
map(
	"n",
	"<leader>tt",
	"?@isTest<CR>0f(hyiw<C-w>s<C-w>j10<C-w>-:term sfdx apex:run:test -y -c -r human -w 5 -t '%:t:r'.<C-r>\"<CR>:nohlsearch<CR>",
	{ desc = "Run Apex test on current test" }
)

map(
	"n",
	"<leader>aa",
	":tabnew /tmp/execute.apex<CR>:silent %delete<CR>p<C-w>:w<CR>",
	{ desc = "Extract selected apex into new temp file" }
)

map(
	"n",
	"<leader>[w",
	":term sf lightning generate component --name  --type lwc --output-dir ~/repos/booknow/repo/BookNow-Software-Dev-Org/force-app/main/default/lwc <S-Left><S-Left><S-Left><S-Left><LEFT>",
	{ desc = "Create LWC" }
)

-- Run apex code in execute anon for the current open file and print the results in a new tab
map(
	"n",
	"<leader>ea",
	"<C-w>v:enew | set ft=log | read !sf apex run -f '#' <CR> ",
	{ desc = "Run Execute Anon on selected code" }
)

-- sf.nvim mappings
-- map("n", "<leader><leader>o", require("sf.org").set_target_org, { desc = "[O]rg Settings for current workspace" })
-- map("n", "<leader><leader>S", require("sf.org").set_global_target_org, { desc = "[S]et global target_org" })
-- map("n", "<leader><leader>f", ':lua require("sf.org").fetch_org_list(true)<CR>', { desc = "[F]etch orgs info" })
--
-- map("n", "<leader>mr", require("sf.org").retrieve_metadata_lists, { desc = "[M]etadata [R]etrieve" })
-- map("n", "<leader>ml", require("sf.org").select_md_to_retrieve, { desc = "[M]etadata [L]ist" })
-- map("n", "<leader>mt", require("sf.org").retrieve_apex_under_cursor, { desc = "[m]etadata [T]his retrieve" })

-- Normal --
-- Disable Space bar since it'll be used as the leader key
nnoremap("<space>", "<nop>")

-- Swap between last two buffers
nnoremap("<leader>'", "<C-^>", { desc = "Switch to last buffer" })

-- Save with leader key
nnoremap("<leader>w", "<cmd>w<cr>", { silent = false })

-- Quit with leader key
nnoremap("<leader>q", "<cmd>q<cr>", { silent = false })

-- Save and Quit with leader key
nnoremap("<leader>z", "<cmd>wq<cr>", { silent = false })

-- Map Oil to <leader>e
nnoremap("<leader>e", function()
	require("oil").toggle_float()
end)

-- Center buffer while navigating
nnoremap("<C-u>", "<C-u>zz")
nnoremap("<C-d>", "<C-d>zz")
nnoremap("{", "{zz")
nnoremap("}", "}zz")
nnoremap("N", "Nzz")
nnoremap("n", "nzz")
nnoremap("G", "Gzz")
nnoremap("gg", "ggzz")
nnoremap("<C-i>", "<C-i>zz")
nnoremap("<C-o>", "<C-o>zz")
nnoremap("%", "%zz")
nnoremap("*", "*zz")
nnoremap("#", "#zz")

-- Press 'S' for quick find/replace for the word under the cursor
nnoremap("S", function()
	local cmd = ":%s/<C-r><C-w>/<C-r><C-w>/gI<Left><Left><Left>"
	local keys = vim.api.nvim_replace_termcodes(cmd, true, false, true)
	vim.api.nvim_feedkeys(keys, "n", false)
end)

-- Press 'H', 'L' to jump to start/end of a line (first/last char)
--nnoremap("L", "$")
--nnoremap("H", "^")

-- Press 'U' for undo
nnoremap("U", "<C-r>")

-- Turn off highlighted results
nnoremap("<leader>no", "<cmd>noh<cr>")

-- Diagnostics

-- Goto next diagnostic of any severity
nnoremap("]d", function()
	vim.diagnostic.goto_next({})
	vim.api.nvim_feedkeys("zz", "n", false)
end)

-- Goto previous diagnostic of any severity
nnoremap("[d", function()
	vim.diagnostic.goto_prev({})
	vim.api.nvim_feedkeys("zz", "n", false)
end)

-- Goto next error diagnostic
nnoremap("]e", function()
	vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
	vim.api.nvim_feedkeys("zz", "n", false)
end)

-- Goto previous error diagnostic
nnoremap("[e", function()
	vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })
	vim.api.nvim_feedkeys("zz", "n", false)
end)

-- Goto next warning diagnostic
nnoremap("]w", function()
	vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.WARN })
	vim.api.nvim_feedkeys("zz", "n", false)
end)

-- Goto previous warning diagnostic
nnoremap("[w", function()
	vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.WARN })
	vim.api.nvim_feedkeys("zz", "n", false)
end)

nnoremap("<leader>d", function()
	vim.diagnostic.open_float({
		border = "rounded",
	})
end)

-- Place all dignostics into a qflist
nnoremap("<leader>ld", vim.diagnostic.setqflist, { desc = "Quickfix [L]ist [D]iagnostics" })

-- Navigate to next qflist item
nnoremap("<leader>cn", ":cnext<cr>zz")

-- Navigate to previos qflist item
nnoremap("<leader>cp", ":cprevious<cr>zz")

-- Open the qflist
nnoremap("<leader>co", ":copen<cr>zz")

-- Close the qflist
nnoremap("<leader>cc", ":cclose<cr>zz")

-- Map MaximizerToggle (szw/vim-maximizer) to leader-m
nnoremap("<leader>m", ":MaximizerToggle<cr>")

-- Resize split windows to be equal size
nnoremap("<leader>=", "<C-w>=")

-- Press leader f to format
nnoremap("<leader>F", ":Format<cr>")

-- Press leader rw to rotate open windows
nnoremap("<leader>rw", ":RotateWindows<cr>", { desc = "[R]otate [W]indows" })

-- Press gx to open the link under the cursor
nnoremap("gx", ":sil !open <cWORD><cr>", { silent = true })

-- TSC autocommand keybind to run TypeScripts tsc
nnoremap("<leader>tc", ":TSC<cr>", { desc = "[T]ypeScript [C]ompile" })

-- Harpoon keybinds --
-- Open harpoon ui
nnoremap("<leader>ho", function()
	harpoon_ui.toggle_quick_menu()
end)

-- Add current file to harpoon
nnoremap("<leader>ha", function()
	harpoon_mark.add_file()
end)

-- Remove current file from harpoon
nnoremap("<leader>hr", function()
	harpoon_mark.rm_file()
end)

-- Remove all files from harpoon
nnoremap("<leader>hc", function()
	harpoon_mark.clear_all()
end)

-- Quickly jump to harpooned files
nnoremap("<leader>1", function()
	harpoon_ui.nav_file(1)
end)

nnoremap("<leader>2", function()
	harpoon_ui.nav_file(2)
end)

nnoremap("<leader>3", function()
	harpoon_ui.nav_file(3)
end)

nnoremap("<leader>4", function()
	harpoon_ui.nav_file(4)
end)

nnoremap("<leader>5", function()
	harpoon_ui.nav_file(5)
end)

-- Git keymaps --
nnoremap("<leader>gb", ":Gitsigns toggle_current_line_blame<cr>")
nnoremap("<leader>gf", function()
	local cmd = {
		"sort",
		"-u",
		"<(git diff --name-only --cached)",
		"<(git diff --name-only)",
		"<(git diff --name-only --diff-filter=U)",
	}

	if not utils.is_git_directory() then
		vim.notify(
			"Current project is not a git directory",
			vim.log.levels.WARN,
			{ title = "Telescope Git Files", git_command = cmd }
		)
	else
		require("telescope.builtin").git_files()
	end
end, { desc = "Search [G]it [F]iles" })

-- Telescope keybinds --
nnoremap("<leader>?", require("telescope.builtin").oldfiles, { desc = "[?] Find recently opened files" })
nnoremap("<leader>sb", require("telescope.builtin").buffers, { desc = "[S]earch Open [B]uffers" })
nnoremap("<leader>sf", function()
	require("telescope.builtin").find_files({ hidden = true })
end, { desc = "[S]earch [F]iles" })
nnoremap("<leader>sh", require("telescope.builtin").help_tags, { desc = "[S]earch [H]elp" })
nnoremap("<leader>sw", require("telescope.builtin").grep_string, { desc = "[S]earch current [W]ord" })
nnoremap("<leader>sg", require("telescope.builtin").live_grep, { desc = "[S]earch by [G]rep" })
nnoremap("<leader>sd", require("telescope.builtin").diagnostics, { desc = "[S]earch [D]iagnostics" })
nnoremap("<leader>sd", require("telescope.builtin").git_files, { desc = "[S]earch [D]iagnostics" })
nnoremap("<leader>cm", require("telescope.builtin").registers, { desc = "[C]heck [M]y registers" })
nnoremap("<leader>fg", require("user.multigrep").live_multigrep, { desc = "[F]ind [M]ultigrep" })

nnoremap("<leader>sc", function()
	require("telescope.builtin").commands(require("telescope.themes").get_dropdown({
		previewer = false,
	}))
end, { desc = "[S]earch [C]ommands" })

nnoremap("<leader>/", function()
	require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
		previewer = false,
	}))
end, { desc = "[/] Fuzzily search in current buffer]" })

nnoremap("<leader>ss", function()
	require("telescope.builtin").spell_suggest(require("telescope.themes").get_dropdown({
		previewer = false,
	}))
end, { desc = "[S]earch [S]pelling suggestions" })

-- LSP Keybinds (exports a function to be used in ../../after/plugin/lsp.lua b/c we need a reference to the current buffer) --
M.map_lsp_keybinds = function(buffer_number)
	nnoremap("<leader>rn", vim.lsp.buf.rename, { desc = "LSP: [R]e[n]ame", buffer = buffer_number })
	nnoremap("<leader>ca", vim.lsp.buf.code_action, { desc = "LSP: [C]ode [A]ction", buffer = buffer_number })

	nnoremap("gd", vim.lsp.buf.definition, { desc = "LSP: [G]oto [D]efinition", buffer = buffer_number })

	-- Telescope LSP keybinds --
	nnoremap(
		"gr",
		require("telescope.builtin").lsp_references,
		{ desc = "LSP: [G]oto [R]eferences", buffer = buffer_number }
	)

	nnoremap(
		"gi",
		require("telescope.builtin").lsp_implementations,
		{ desc = "LSP: [G]oto [I]mplementation", buffer = buffer_number }
	)

	nnoremap(
		"<leader>bs",
		require("telescope.builtin").lsp_document_symbols,
		{ desc = "LSP: [B]uffer [S]ymbols", buffer = buffer_number }
	)

	nnoremap(
		"<leader>ps",
		require("telescope.builtin").lsp_workspace_symbols,
		{ desc = "LSP: [P]roject [S]ymbols", buffer = buffer_number }
	)

	-- See `:help K` for why this keymap
	nnoremap("K", vim.lsp.buf.hover, { desc = "LSP: Hover Documentation", buffer = buffer_number })
	nnoremap("<leader>k", vim.lsp.buf.signature_help, { desc = "LSP: Signature Documentation", buffer = buffer_number })
	inoremap("<C-k>", vim.lsp.buf.signature_help, { desc = "LSP: Signature Documentation", buffer = buffer_number })

	-- Lesser used LSP functionality
	nnoremap("gD", vim.lsp.buf.declaration, { desc = "LSP: [G]oto [D]eclaration", buffer = buffer_number })
	nnoremap("td", vim.lsp.buf.type_definition, { desc = "LSP: [T]ype [D]efinition", buffer = buffer_number })
end

-- Symbol Outline keybind
nnoremap("<leader>so", ":SymbolsOutline<cr>")

-- Vim Illuminate keybinds
nnoremap("<leader>]", function()
	illuminate.goto_next_reference()
	vim.api.nvim_feedkeys("zz", "n", false)
end, { desc = "Illuminate: Goto next reference" })

nnoremap("<leader>[", function()
	illuminate.goto_prev_reference()
	vim.api.nvim_feedkeys("zz", "n", false)
end, { desc = "Illuminate: Goto previous reference" })

-- Open Copilot panel
nnoremap("<leader>oc", function()
	require("copilot.panel").open({})
end, { desc = "[O]pen [C]opilot panel" })

-- Insert --
-- Map jj to <esc>
inoremap("jj", "<esc>")

-- Visual --
-- Disable Space bar since it'll be used as the leader key
vnoremap("<space>", "<nop>")

-- Press 'H', 'L' to jump to start/end of a line (first/last char)
vnoremap("L", "$<left>")
vnoremap("H", "^")

-- Paste without losing the contents of the register
xnoremap("<leader>p", '"_dP')

-- Reselect the last visual selection
xnoremap("<", function()
	vim.cmd("normal! <<")
	vim.cmd("normal! gv")
end)

xnoremap(">", function()
	vim.cmd("normal! >>")
	vim.cmd("normal! gv")
end)

-- Terminal --
-- Enter normal mode while in a terminal
tnoremap("<esc>", [[<C-\><C-n>]])

-- Reenable default <space> functionality to prevent input delay
tnoremap("<space>", "<space>")

-- Move selected text up/down in visual mode
map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '>-2<CR>gv=gv")

return M
