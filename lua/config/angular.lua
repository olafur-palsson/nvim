vim.api.nvim_create_user_command("AngularSwitch2", function()
	local fname = vim.fn.expand("%:t") -- current filename
	local base = fname:match("(.+)%.%w+$") -- e.g., component
	local ext = fname:match("^.+%.(%w+)$") -- e.g., ts
	local dir = vim.fn.expand("%:p:h") -- full directory path

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

	local next_file
	if ext == "ts" then
		next_file = string.format("%s/%s.html", dir, base)
	elseif ext == "html" then
		local style = find_style_file()
		if style then
			next_file = string.format("%s/%s.%s", dir, base, style)
		else
			print("No matching style file found.")
			return
		end
	elseif vim.tbl_contains(style_exts, ext) then
		next_file = string.format("%s/%s.ts", dir, base)
	else
		print("Unsupported file type.")
		return
	end

	vim.cmd("edit " .. next_file)
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
	elseif ext == "html" then
		target_ext = find_style_file()
		if not target_ext then
			print("No style file found.")
			return
		end
	elseif vim.tbl_contains(style_exts, ext) then
		target_ext = "ts"
	else
		print("Unsupported file type.")
		return
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
end, {})

vim.keymap.set("n", "<Leader>ng", "<cmd>AngularSwitch<CR>")
