local dap = require("dap")
local dapui = require("dapui")

local function find_cs_project_root(start_dir)
	local function is_project_dir(dir)
		for _, name in ipairs(vim.fn.readdir(dir)) do
			if name:match("%.csproj$") or name:match("%.sln$") then
				return true
			end
		end
		return false
	end
	local function parent(path)
		return vim.fn.fnamemodify(path, ":h")
	end
	local dir = start_dir or vim.fn.expand("%:p:h")
	while dir and dir ~= "/" do
		if is_project_dir(dir) then
			return dir
		end
		dir = parent(dir)
	end
	return nil
end

local function find_csproj_in_dir(dir)
	local handle = vim.loop.fs_scandir(dir)
	if not handle then
		return nil
	end
	while true do
		local name, type = vim.loop.fs_scandir_next(handle)
		if not name then
			break
		end
		if type == "file" and name:match("%.csproj$") then
			return dir .. "/" .. name
		end
	end
	return nil
end

local function find_dll_file(dir)
	local dir = find_cs_project_root(start_dir)
	local csproj = find_csproj_in_dir(start_dir)
	if csproj == nil then
		return "/no/path/to/file.dll"
	end
	local csprojname = vim.fn.fnamemodify(csproj, ":t")
	local dll_name = string.gsub(csprojname, "csproj", "dll", 1)
	local function scan(path)
		local handle = vim.loop.fs_scandir(path)
		if not handle then
			return nil
		end
		while true do
			local name, type = vim.loop.fs_scandir_next(handle)
			if not name then
				break
			end
			local full_path = path .. "/" .. name
			if type == "file" and name == dll_name then
				return full_path
			elseif type == "directory" then
				local isnot5 = not name:match("[567]")
				if isnot5 then
					local found = scan(full_path)
					if found then
						return found
					end
				end
			end
		end
		return nil
	end
	return scan(dir)
end

dapui.setup()

dap.adapters.coreclr = {
	type = "executable",
	command = "/home/oli/Data/Downloads/netcoredbg/netcoredbg", --add your netcoredbg executable path
	args = { "--interpreter=vscode" },
}

dap.configurations.cs = {
	{
		type = "coreclr",
		request = "launch",
		name = "Launch .NET Core App",
		program = function()
			return find_dll_file(vim.fn.getcwd(0))
		end,
		args = {},
		cwd = vim.fn.getcwd(0), --root directory of your project
		env = {
			ASPNETCORE_ENVIRONMENT = "Development",
			ASPNETCORE_URLS = "https://localhost:5001;http://localhost:5000",
		},
		console = "integratedTerminal",
	},
}

--breakpoint icons
vim.fn.sign_define(
	"DapBreakpoint",
	{ text = "🛑", texthl = "DapBreakpoint", linehl = "DapBreakpoint", numhl = "DapBreakpoint" }
)
vim.fn.sign_define(
	"DapStopped",
	{ text = "▶️", texthl = "DapStopped", linehl = "DapStopped", numhl = "DapStopped" }
)
vim.api.nvim_create_user_command("CsharpDebugDll", function()
	local projectRoot = find_dll_file(vim.fn.getcwd(0))
	print(projectRoot)
end, {})
vim.api.nvim_create_user_command("CsharpProjectRoot", function()
	local projectRoot = find_cs_project_root(vim.fn.getcwd(0))
	print(projectRoot)
end, {})
-- Run debugger
--
vim.keymap.set("n", "<F5>", function()
	print("Starting debugger")
	local cwd = vim.fn.getcwd(0)
	local root = find_cs_project_root(cwd)

	local dll = find_dll_file(cwd)
	local config = {
		{
			type = "coreclr",
			request = "launch",
			name = "Launch .NET Core App",
			program = dll,
			args = {},
			cwd = root, --root directory of your project
			env = {
				ASPNETCORE_ENVIRONMENT = "Development",
				ASPNETCORE_URLS = "<https://localhost:5001>;<http://localhost:5000>",
			},
			console = "integratedTerminal",
		},
	}

	local function run_bash_cmd(cmd, cwd)
		return vim.fn.system({ "bash", "-c", cmd }, cwd)
	end

	-- Example
	print("Building project...")
	local output = run_bash_cmd("dotnet build --property WarningLevel=0", root)
	local lines = vim.split(output, "\n", { plain = true, trimempty = true })
	local filtered = vim.tbl_filter(function(line)
		return not line:match(" warning ")
	end, lines)
	local joined = table.concat(filtered, "\n")
	print(joined, dll, root)
	require("dap").continue()
end)

--toggle breakpoint
vim.api.nvim_set_keymap("n", "<leader>dt", ":DapToggleBreakpoint<CR>", { noremap = true })

-- start debugging
vim.api.nvim_set_keymap("n", "<leader>dc", ":DapContinue<CR>", { noremap = true })

--reset layout
vim.api.nvim_set_keymap("n", "<leader>dr", "<cmd>lua require('dapui').open({reset = true})<CR>", { noremap = true })

--auto open & close the UI panes
dap.listeners.before.attach.dapui_config = function()
	dapui.open()
end
dap.listeners.before.launch.dapui_config = function()
	dapui.open()
end
dap.listeners.before.event_terminated.dapui_config = function()
	--dapui.close()
end
dap.listeners.before.event_exited.dapui_config = function()
	-- dapui.close()
end
