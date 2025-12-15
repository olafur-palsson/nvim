vim.api.nvim_create_user_command("AngularCss", function()
	local fname = vim.fn.expand("%:t")
	local base = fname:match("(.+)%.%w+$")
	local ext = fname:match("^.+%.(%w+)$")
	local dir = vim.fn.expand("%:p:h")
	local style_exts = { "scss", "css", "less" }

    if ext == 'ts' then
	    vim.cmd("AngularSwitch")
    end


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
  local ext  = fname:match("^.+%.(%w+)$")
  local dir  = vim.fn.expand("%:p:h")

  local target_ext = (ext == "ts") and "html" or "ts"
  local target_file = vim.fn.fnamemodify(string.format("%s/%s.%s", dir, base, target_ext), ":p")

  -- Search all windows in all tabs
  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
      local buf = vim.api.nvim_win_get_buf(win)
      local name = vim.api.nvim_buf_get_name(buf)
      if name == target_file then
        vim.api.nvim_set_current_tabpage(tab)
        vim.api.nvim_set_current_win(win)
        return
      end
    end
  end

  -- Not open anywhere → open new tab
  vim.cmd("tabedit " .. target_file)
end, {})

vim.keymap.set("n", "<Leader>ng", "<cmd>AngularSwitch<CR>")
vim.keymap.set("n", "<Leader>cs", "<cmd>AngularCss<CR>")

vim.api.nvim_create_autocmd("FileType", {
  pattern = "htmlangular",
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.expandtab = true
  end,
})
