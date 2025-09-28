return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"nvim-neotest/nvim-nio",
			"theHamsta/nvim-dap-virtual-text",
			opts = function()
				local dap = require("dap")
				require("netcoredbg-macOS-arm64").setup(dap)
			end,
		},
		config = function()
			local dap = require "dap"
			local ui = require "dapui"

			require("nvim-dap-virtual-text").setup {
				commented = true,
			}

			require("dapui").setup({
				controls = {
					element = "repl",
					enabled = true,
					icons = {
						disconnect = "",
						pause = "",
						play = "",
						run_last = "",
						step_back = "",
						step_into = "",
						step_out = "",
						step_over = "",
						terminate = "",
					},
				},
				element_mappings = {},
				expand_lines = true,
				floating = {
					border = "rounded",
					mappings = {
						close = { "q", "<Esc>" },
					},
				},
				force_buffers = true,
				icons = {
					collapsed = "",
					current_frame = "",
					expanded = "",
				},
				layouts = {
					{
						elements = {
							{
								id = "scopes",
								size = 0.25,
							},
							{
								id = "breakpoints",
								size = 0.25,
							},
							{
								id = "stacks",
								size = 0.25,
							},
							{
								id = "watches",
								size = 0.25,
							},
						},
						position = "right",
						size = 50,
					},
					{
						elements = {
							{
								id = "repl",
								size = 0.5,
							},
							{
								id = "console",
								size = 0.5,
							},
						},
						position = "bottom",
						size = 10,
					},
				},
				mappings = {
					edit = "e",
					expand = { "<CR>", "<2-LeftMouse>" },
					open = "o",
					remove = "d",
					repl = "r",
					toggle = "t",
				},
				render = {
					indent = 1,
					max_value_lines = 100,
				},
			})

			dap.listeners.after.event_initialized["dapui_config"] = function()
				ui.open()
			end

			dap.adapters.chrome = {
				type = "executable",
				command = "node",
				args = {os.getenv("HOME") .. "/repos/programs/vscode-chrome-debug/out/src/chromeDebug.js"}
			}

			dap.configurations.javascript = { -- change this to javascript if needed
				{
					name = "chrome",
					type = "chrome",
					request = "attach",
					program = "${file}",
					cwd = vim.fn.getcwd(),
					sourceMaps = true,
					protocol = "inspector",
					port = 9222,
					webRoot = "${workspaceFolder}"
				}
			}

			local enter_launch_url = function()
				local co = coroutine.running()
				return coroutine.create(function()
					vim.ui.input({ prompt = "Enter URL: ", default = "http://localhost:" }, function(url)
						if url == nil or url == "" then
							return
						else
							coroutine.resume(co, url)
						end
					end)
				end)
			end

			local dotnet_build_project = function()
				local default_path = vim.fn.getcwd() .. "/"

				if vim.g["dotnet_last_proj_path"] ~= nil then
					default_path = vim.g["dotnet_last_proj_path"]
				end

				local path = vim.fn.input("Path to your *proj file", default_path, "file")

				vim.g["dotnet_last_proj_path"] = path

				local cmd = "dotnet build -c Debug " .. path .. " > /dev/null"

				print("")
				print("Cmd to execute: " .. cmd)

				local f = os.execute(cmd)

				if f == 0 then
					print("\nBuild: ✔️ ")
				else
					print("\nBuild: ❌ (code: " .. f .. ")")
				end
			end

			local dotnet_get_dll_path = function()
				local request = function()
					local pattern = vim.fn.getcwd() .. '/bin/Debug/**/*.dll'
					local files = vim.fn.glob(pattern, false, true)

					-- Filter out common dependency DLLs to find the main app DLL
					local filtered = {}
					for _, file in ipairs(files) do
						local filename = vim.fn.fnamemodify(file, ':t')
						-- Skip common dependency patterns
						if not (filename:match('^Microsoft%.') or
								filename:match('^System%.') or
								filename:match('^AWS') or
								filename:match('%.resources%.dll$') or
								filename:match('^Newtonsoft%.') or
								filename:match('^NuGet%.')) then
							table.insert(filtered, file)
						end
					end

					if #filtered == 1 then
						return filtered[1]
					elseif #filtered > 1 then
						-- Multiple candidates, let user choose
						return vim.fn.input('Multiple DLLs found. Path to dll: ', filtered[1], 'file')
					else
						return vim.fn.input('Path to dll: ', pattern, 'file')
					end
				end

				if vim.g['dotnet_last_dll_path'] == nil then
					vim.g['dotnet_last_dll_path'] = request()
				else
					if vim.fn.confirm('Do you want to change the path to dll?\n' .. vim.g['dotnet_last_dll_path'], '&yes\n&no', 2) == 1 then
						vim.g['dotnet_last_dll_path'] = request()
					end
				end

				return vim.g['dotnet_last_dll_path']
			end

			dap.adapters.coreclr = {
				type = 'executable',
				command = "/usr/local/netcoredbg",
				args = {'--interpreter=vscode', '--engineLogging=/tmp/netcoredbg.log'},
				env = {
					CORECLR_DEBUG_LIBRARY_PATH = '/usr/local/netcoredbg'
				}
			}

			dap.set_log_level('TRACE')

			-- prevent auto-close when program terminates/exits
			dap.listeners.before.event_terminated["keep_open"] = function() end
			dap.listeners.before.event_exited["keep_open"] = function() end

			local dapui = require("dapui")
			vim.keymap.set("n", "<leader>dq", function()
				-- try to end any active session, but don't error if none
				pcall(dap.terminate)                  -- politely ask adapter to end
				pcall(dap.disconnect, { terminateDebuggee = true })
				pcall(require("dap.repl").close)
				dapui.close()
				-- also close any floating dap windows (stacks/scopes hovers, etc.)
				for _, win in ipairs(vim.api.nvim_list_wins()) do
					local cfg = vim.api.nvim_win_get_config(win)
					if cfg and cfg.relative ~= "" then
						pcall(vim.api.nvim_win_close, win, true)
					end
				end
			end, { desc = "DAP Quit (close UI & REPL)" })

			dap.configurations.cs = {
				{
					type = "coreclr",
					name = "Launch - coreclr (nvim-dap)",
					request = "launch",
					program = function()
						if vim.fn.confirm("Rebuild first?", "&yes\n&no", 2) == 1 then
							dotnet_build_project()
						end
						local dll_path = dotnet_get_dll_path()
						return dll_path
					end,
					cwd = "${workspaceFolder}",
					console = "internalConsole",
					stopAtEntry = false,
				},
			}
		end,
		-- stylua: ignore
		keys = {
			{ "<leader>nU", function() require("dapui").toggle() end, desc = "Toggle UI", },
			{ "<leader>nt", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint", },
			{ "<F10>", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint", },
			{ "<leader>ns", function() require("dap").continue() end, desc = "Start", },
			{ "<F5>", function() require("dap").continue() end, desc = "DAP Continue/Start" },
			{ "<leader>nc", function() require("dap").continue() end, desc = "Continue", },
			{ "<leader>no", function() require("dap").step_over() end, desc = "Step Over", },
			{ "<F1>", function() require("dap").step_over() end, desc = "Step Over", },
			{ "<leader>ni", function() require("dap").step_into() end, desc = "Step Into", },
			{ "<F2>", function() require("dap").step_into() end, desc = "Step Into", },
			{ "<leader>nu", function() require("dap").step_out() end, desc = "Step Out", },
			{ "<F3>", function() require("dap").step_out() end, desc = "Step Out", },
			{ "<leader>nb", function() require("dap").step_back() end, desc = "Step Back", },
			{ "<F4>", function() require("dap").step_back() end, desc = "Step Back", },
			{ "<leader>nR", function() require("dap").run_to_cursor() end, desc = "Run to Cursor", },
			{ "<F6>", function() require("dap").run_to_cursor() end, desc = "Run to Cursor", },
			{ "<leader>nq", function() require("dap").close() end, desc = "Quit", },
			{ "<leader>nx", function() require("dap").terminate() end, desc = "Terminate", },
			{ "<leader>nE", function() require("dapui").eval(vim.fn.input "[Expression] > ") end, desc = "Evaluate Input", },
			{ "<leader>nC", function() require("dap").set_breakpoint(vim.fn.input "[Condition] > ") end, desc = "Conditional Breakpoint", },
			{ "<leader>nD", function() require("dap").disconnect() end, desc = "Disconnect", },
			{ "<leader>ne", function() require("dapui").eval() end, mode = {"n", "v"}, desc = "Evaluate", },
			{ "<leader>ng", function() require("dap").session() end, desc = "Get Session", },
			{ "<leader>dh", function() require("dap.ui.widgets").hover() end, desc = "Hover Variables", },
			{ "<leader>nS", function() require("dap.ui.widgets").scopes() end, desc = "Scopes", },
			{ "<leader>np", function() require("dap").pause.toggle() end, desc = "Pause", },
			{ "<leader>nr", function() require("dap").repl.toggle() end, desc = "Toggle REPL", },
		},
	},
}
