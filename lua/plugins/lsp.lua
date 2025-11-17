return {
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPost" },
		cmd = { "LspInfo", "LspInstall", "LspUninstall", "Mason" },
		dependencies = {
			-- Plugin and UI to automatically install LSPs to stdpath
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",

			"hrsh7th/cmp-nvim-lsp",
			-- Install none-ls for diagnostics, code actions, and formatting
			"nvimtools/none-ls.nvim",

			-- Install neodev for better nvim configuration and plugin authoring via lsp configurations
			"folke/neodev.nvim",

			-- Progress/Status update for LSP
			{ "j-hui/fidget.nvim", tag = "legacy" },
		},
		config = function()
			local null_ls = require("null-ls")
			local map_lsp_keybinds = require("user.keymaps").map_lsp_keybinds -- Has to load keymaps before pluginslsp

			-- Use neodev to configure lua_ls in nvim directories - must load before lspconfig
			require("neodev").setup()

			-- Setup mason so it can manage 3rd party LSP servers
			require("mason").setup({
				ui = {
					border = "rounded",
				},
			})

			-- Ensure Angular language server is installed via Mason
			require("mason-lspconfig").setup({
				ensure_installed = { "angularls" },
			})

			-- Auto-install apex-language-server if not present
			-- (apex_ls is not supported by mason-lspconfig's ensure_installed)
			local mason_registry = require("mason-registry")
			if not mason_registry.is_installed("apex-language-server") then
				vim.notify("Installing apex-language-server...", vim.log.levels.INFO)
				local apex_pkg = mason_registry.get_package("apex-language-server")
				apex_pkg:install()
			end

			-- Override tsserver diagnostics to filter out specific messages
			local messages_to_filter = {
				"This may be converted to an async function.",
				"'_Assertion' is declared but never used.",
				"'__Assertion' is declared but never used.",
				"The signature '(data: string): string' of 'atob' is deprecated.",
				"The signature '(data: string): string' of 'btoa' is deprecated.",
			}

			local function tsserver_on_publish_diagnostics_override(_, result, ctx, config)
				local filtered_diagnostics = {}

				for _, diagnostic in ipairs(result.diagnostics) do
					local found = false
					for _, message in ipairs(messages_to_filter) do
						if diagnostic.message == message then
							found = true
							break
						end
					end
					if not found then
						table.insert(filtered_diagnostics, diagnostic)
					end
				end

				result.diagnostics = filtered_diagnostics

				vim.lsp.diagnostic.on_publish_diagnostics(_, result, ctx, config)
			end

			-- LSP servers to install (see list here: https://github.com/williamboman/mason-lspconfig.nvim#available-lsp-servers )
			local servers = {
				bashls = {},
				-- clangd = {},
				cssls = {},
				gleam = {},
				graphql = {},
				-- Angular Language Server
				angularls = {
					-- Start with stdio; we will inject probe locations per project root
					cmd = { "ngserver", "--stdio" },
					filetypes = { "typescript", "html", "typescriptreact", "typescript.tsx" },
					root_dir = require("lspconfig.util").root_pattern("angular.json", "nx.json", "project.json"),
					on_new_config = function(new_config, new_root_dir)
						-- Help Angular LS find workspace TypeScript and Angular packages
						new_config.cmd = {
							"ngserver",
							"--stdio",
							"--tsProbeLocations",
							new_root_dir,
							"--ngProbeLocations",
							new_root_dir,
						}
					end,
				},
				html = {},
				jsonls = {},
				lua_ls = {
					settings = {
						Lua = {
							workspace = { checkThirdParty = false },
							telemetry = { enabled = false },
						},
					},
				},
				marksman = {},
				ocamllsp = {},
				prismals = {},
				pyright = {},
				solidity = {},
				sqlls = {},
				tailwindcss = {
					-- Limit where Tailwind LS attaches to projects that actually have config
					root_dir = require("lspconfig.util").root_pattern(
						"tailwind.config.js",
						"tailwind.config.cjs",
						"tailwind.config.mjs",
						"tailwind.config.ts",
						"postcss.config.js",
						"postcss.config.cjs",
						"postcss.config.mjs",
						"package.json"
					),
					settings = {
						tailwindCSS = {
							files = {
								exclude = {
									"**/node_modules/**",
									"**/.git/**",
									"**/dist/**",
									"**/build/**",
									"**/coverage/**",
									"**/test/**",
									"**/tests/**",
									"**/fixtures/**",
								},
							},
						},
					},
					-- Suppress noisy Node experimental warnings from this server only
					cmd_env = { NODE_NO_WARNINGS = "1" },
				},
				ts_ls = {
					settings = {
						experimental = {
							enableProjectDiagnostics = true,
						},
					},
					handlers = {
						["textDocument/publishDiagnostics"] = vim.lsp.with(
							tsserver_on_publish_diagnostics_override,
							{}
						),
					},
				},
				yamlls = {},
				apex_ls = {
					cmd = {
					"java",
					"-jar",
					vim.fn.stdpath("data") .. "/mason/packages/apex-language-server/extension/dist/apex-jorje-lsp.jar",
				},
					apex_jar_path = vim.fn.stdpath("data")
					.. "/mason/packages/apex-language-server/extension/dist/apex-jorje-lsp.jar",
					filetypes = { "apex" },
					apex_enable_semantic_errors = false,
					apex_enable_completion_statistics = false,
				},
				omnisharp = {
					cmd = { "omnisharp" },
				},
			}

			-- Default handlers for LSP
			local default_handlers = {
				["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" }),
				["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" }),
			}

			-- nvim-cmp supports additional completion capabilities
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			local default_capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

			---@diagnostic disable-next-line: unused-local
			local on_attach = function(client, buffer_number)
				-- Pass the current buffer to map lsp keybinds
				map_lsp_keybinds(buffer_number)

				-- Show initialization notifications for omnisharp
				if client.name == "omnisharp" then
					Snacks.notify("OmniSharp: Initializing C# language server...", {
						title = "LSP",
						icon = "󰌗",
					})

					-- Check when omnisharp is ready by monitoring server capabilities
					local timer = vim.loop.new_timer()
					local check_count = 0
					timer:start(1000, 1000, vim.schedule_wrap(function()
						check_count = check_count + 1
						if client.server_capabilities and client.server_capabilities.completionProvider then
							timer:stop()
							timer:close()
							Snacks.notify("OmniSharp: C# IntelliSense ready!", {
								title = "LSP",
								icon = "󰌗",
								level = "info",
							})
						elseif check_count > 60 then -- Stop checking after 60 seconds
							timer:stop()
							timer:close()
							Snacks.notify("OmniSharp: Initialization timeout", {
								title = "LSP",
								icon = "󰌗",
								level = "warn",
							})
						end
					end))
				end

				-- Create a command `:Format` local to the LSP buffer
				vim.api.nvim_buf_create_user_command(buffer_number, "Format", function(_)
					vim.lsp.buf.format({
						filter = function(format_client)
							-- Use Prettier to format TS/JS if it's available
							return format_client.name ~= "ts_ls" or not null_ls.is_registered("prettier")
						end,
					})
				end, { desc = "LSP: Format current buffer with LSP" })
			end

			-- Iterate over our servers and set them up
			for name, config in pairs(servers) do
				vim.lsp.config[name] = {
					capabilities = default_capabilities,
					cmd = config.cmd,
					filetypes = config.filetypes,
					handlers = vim.tbl_deep_extend("force", {}, default_handlers, config.handlers or {}),
					on_attach = on_attach,
					settings = config.settings,
					root_dir = config.root_dir,
					on_new_config = config.on_new_config,
				}
				-- Enable the LSP server
				vim.lsp.enable(name)
			end

			-- Congifure LSP linting, formatting, diagnostics, and code actions
			local formatting = null_ls.builtins.formatting
			local diagnostics = null_ls.builtins.diagnostics
			local code_actions = null_ls.builtins.code_actions

			null_ls.setup({
				border = "rounded",
				sources = {
					-- formatting
					-- formatting.eslint_d,
					formatting.stylua,
					formatting.ocamlformat,

					-- -- diagnostics
					-- diagnostics.eslint_d.with({
					-- 	condition = function(utils)
					-- 		return utils.root_has_file({ ".eslintrc.js", ".eslintrc.cjs", ".eslintrc.json" })
					-- 	end,
					-- }),
					--
					-- -- code actions
					-- code_actions.eslint_d.with({
					-- 	condition = function(utils)
					-- 		return utils.root_has_file({ ".eslintrc.js", ".eslintrc.cjs", ".eslintrc.json" })
					-- 	end,
					-- }),
				},
			})

			-- Configure borderd for LspInfo ui
			require("lspconfig.ui.windows").default_options.border = "rounded"

			-- Configure diagostics border
			vim.diagnostic.config({
				float = {
					border = "rounded",
				},
			})
		end,
	},
}
