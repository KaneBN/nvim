local lsp = require('lsp-zero')

lsp.preset('recommended')

lsp.ensure_installed({
	'eslint',
	'sumneko_lua'
})

local cmp = require('cmp')
local cmp_select = {behaviour = cmp.SelectBehavior.Select}
local cmp_mappings = lsp.defaults.cmp_mappings({
	['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
	['<C-p>'] = cmp.mapping.select_next_item(cmp_select)
})

lsp.on_attach(function(client, bufnr)
	local opts = {buffer = bufnr, remap = false}

	vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
	vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
end)

lsp.set_preferences({
    sign_icons = { }
})

lsp.setup()


