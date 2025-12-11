vim.api.nvim_create_user_command("AngularCss", function()
	local fname = vim.fn.expand("%:t")
	local base = fname:match("(.+)%.%w+$")
	local ext = fname:match("^.+%.(%w+)$")
	local dir = vim.fn.expand("%:p:h")
	local style_exts = { "scss", "css", "less" }

	local function find_style_file()
		for _, se in ipairs(style_exts) do
			local f = string.format("%s/%s.%s", dir, base, se)
			if vim.fn.filereadable(f) == 1 then
				return se
			end
		end
		return nil
	end

	local target_ext = find_style_file()
	if not target_ext then
		return
	end
    local target_file = string.format("%s/%s.%s", dir, base, target_ext)

	-- Check if already open in any window
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		local path = vim.api.nvim_buf_get_name(buf)
		if path == target_file then
			vim.api.nvim_set_current_win(win) -- jump to it
			return
		end
	end

	-- Not open → open split
	vim.cmd("vsplit " .. target_file)
	vim.cmd("vertical resize 60")
end, {})

vim.api.nvim_create_user_command("AngularSwitch", function()
	local fname = vim.fn.expand("%:t")
	local base = fname:match("(.+)%.%w+$")
	local ext = fname:match("^.+%.(%w+)$")
	local dir = vim.fn.expand("%:p:h")

	local target_ext
	if ext == "ts" then
		target_ext = "html"
	else
		target_ext = "ts"
	end

	local target_file = string.format("%s/%s.%s", dir, base, target_ext)

	-- check if the file is already open in a tab
	for _, tabnr in ipairs(vim.api.nvim_list_tabpages()) do
		local win = vim.api.nvim_tabpage_get_win(tabnr)
		local buf = vim.api.nvim_win_get_buf(win)
		local name = vim.api.nvim_buf_get_name(buf)
		if name == vim.fn.fnamemodify(target_file, ":p") then
			vim.cmd("tabnext " .. vim.api.nvim_tabpage_get_number(tabnr))
			return
		end
	end

	-- open in a new tab
	vim.cmd("tabedit " .. target_file)
	vim.cmd("")
end, {})

vim.keymap.set("n", "<Leader>ng", "<cmd>AngularSwitch<CR>")
vim.keymap.set("n", "<Leader>cs", "<cmd>AngularCss<CR>")
