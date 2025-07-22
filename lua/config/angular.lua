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
	local target_file = string.format("%s/%s.%s", dir, base, target_ext)
	if vim.fn.filereadable(target_file) == 1 then
		-- Open in vertical split, resize to 30 characters wide
		vim.cmd("vsplit " .. target_file)
		vim.cmd("vertical resize 60")
	end
end, {})

vim.api.nvim_create_user_command("AngularSwitch", function()
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
	vim.cmd("AngularCss")
end, {})

vim.keymap.set("n", "<Leader>ng", "<cmd>AngularSwitch<CR>")
