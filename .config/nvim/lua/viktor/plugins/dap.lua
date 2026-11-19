return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			-- UI
			{
				"rcarriga/nvim-dap-ui",
				dependencies = { "nvim-neotest/nvim-nio" },
				config = function()
					local dap, dapui = require("dap"), require("dapui")
					dapui.setup()

					dap.listeners.after.event_initialized["dapui_config"] = function()
						dapui.open()
					end
					dap.listeners.before.event_terminated["dapui_config"] = function()
						dapui.close()
					end
					dap.listeners.before.event_exited["dapui_config"] = function()
						dapui.close()
					end
				end,
			},
			-- inline variable values
			{
				"theHamsta/nvim-dap-virtual-text",
				opts = {},
			},
			-- Go: wires delve adapter + launch configs (debug file, package, test)
			{
				"leoluz/nvim-dap-go",
				opts = {},
			},
			-- auto-install & configure debug adapters via mason
			{
				"jay-babu/mason-nvim-dap.nvim",
				dependencies = { "williamboman/mason.nvim" },
				opts = {
					-- delve is built with `go install`; skip it where Go is missing
					ensure_installed = vim.fn.executable("go") == 1 and { "python", "js", "delve" }
						or { "python", "js" },
					automatic_installation = true,
				},
			},
		},
		config = function()
			local dap = require("dap")

			-- JS/TS: vscode-js-debug server started by mason's js-debug-adapter install.
			-- mason-nvim-dap only installs the binary for "js"; it has no default
			-- handler that wires up the pwa-node adapter, so do it by hand.
			local js_debug_path = vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js"
			dap.adapters["pwa-node"] = {
				type = "server",
				host = "localhost",
				port = "${port}",
				executable = {
					command = "node",
					args = { js_debug_path, "${port}" },
				},
			}

			-- Python: debugpy
			dap.adapters.python = {
				type = "executable",
				command = "python3",
				args = { "-m", "debugpy.adapter" },
			}
			dap.configurations.python = {
				{
					type = "python",
					request = "launch",
					name = "Launch file",
					program = "${file}",
					pythonPath = function()
						return "python3"
					end,
				},
			}

			-- JS/TS: run current file with node so console.log LeetCode snippets are debuggable directly
			for _, lang in ipairs({ "javascript", "typescript" }) do
				dap.configurations[lang] = {
					{
						type = "pwa-node",
						request = "launch",
						name = "Launch current file (node)",
						program = "${file}",
						cwd = "${workspaceFolder}",
						sourceMaps = true,
						skipFiles = { "<node_internals>/**" },
					},
					{
						type = "pwa-node",
						request = "attach",
						name = "Attach to node --inspect process",
						processId = require("dap.utils").pick_process,
						cwd = "${workspaceFolder}",
					},
				}
			end
		end,
	},
}
