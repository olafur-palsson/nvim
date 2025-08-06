local ts_utils = require("nvim-treesitter.ts_utils")

local function TreeSitterIdentify()
	local node = ts_utils.get_node_at_cursor()
	local type = "cursor"
	local correct_node
	while node:parent() ~= nil do
		type = node:type() .. " > " .. type
		node = node:parent()
	end

	print(type)
end

local function list_children(node)
	local children = {}
	for i = 0, node:child_count() - 1 do
		local child = node:child(i)
		table.insert(children, child)
	end
	return children
end

local function TreeSitterIdentifyChildren()
	local node = ts_utils.get_node_at_cursor()
	local children = list_children(node)

	local child_list = "Children from: " .. node:type()

	for _, child in ipairs(children) do
		child_list = child_list .. "\n" .. child:type()
	end
	print(child_list)
end

local function FindParentNode(node, target_type)
	local type = "cursor"
	local correct_node
	while node:parent() ~= nil do
		if node:type() == target_type then
			type = node:type() .. " > " .. type
			correct_node = node
			break
		end
		type = node:type() .. " > " .. type
		node = node:parent()
	end

	if correct_node == nil then
		return nil
	end

	return correct_node, type
end

local function find_previous_siblings(end_node, list)
	local start_node = end_node
	local sibling = start_node:prev_sibling()
	local is_in_list = function(str)
		for _, value in ipairs(list) do
			if str == value then
				return true
			end
		end
		return false
	end

	if sibling ~= nil then
		local found_list = {}
		local sibling_type = sibling:type()
		if not found_list[sibling_type] and is_in_list(sibling_type) then
			start_node = sibling
			found_list[sibling_type] = true
		end
	end
	return start_node
end

local function find_parent_list(node, list)
	for _, word in ipairs(list) do
		local parent = FindParentNode(node, word)
		if parent ~= nil then
			return parent
		end
	end
	return nil
end

local function find_child(node, type_name)
	for i = 0, node:named_child_count() - 1 do
		local child = node:named_child(i)
		if child:type() == type_name then
			return child
		end
	end
	return nil
end

local function get_line_length(row)
	local line = vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1]
	return line and #line or 0
end

local function is_line_whitespace_after_col(bufnr, row, col)
	local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1]
	if not line then
		return true
	end
	return line:sub(col + 2):match("^%s*$") ~= nil
end

local function is_line_whitespace_until_col(bufnr, row, col)
	local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1]
	if not line then
		return true
	end
	return line:sub(1, col):match("^%s*$") ~= nil
end

local function get_char_at(row, col)
	local line = vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1]
	if not line then
		return nil
	end
	return line:sub(col + 1, col + 1)
end

local function move_selection_based_on_curlys(start_row, start_col, end_row, end_col)
	local start_char = get_char_at(start_row, start_col)
	if start_char == "{" then
		if is_line_whitespace_after_col(vim.api.nvim_get_current_buf(), start_row, start_col) then
			start_row = start_row + 1
			start_col = 0
		else
			start_col = start_col + 1
		end
	end

	while end_col >= 0 do
		local prev = get_char_at(end_row, end_col)
		if prev:match("^%s*$") then
			end_col = end_col - 1
		else
			break
		end
	end

	local end_char = get_char_at(end_row, end_col)
	if end_char == "}" then
		if is_line_whitespace_until_col(vim.api.nvim_get_current_buf(), end_row, end_col) then
			end_row = end_row - 1
			end_col = get_line_length(end_row)
			if end_col > 0 then
				end_col = end_col - 1
			end
		else
			end_col = end_col - 1
		end
	end

	return start_row, start_col, end_row, end_col
end

local function SelectText(start_row, start_col, end_row, end_col)
	if is_line_whitespace_until_col(vim.api.nvim_get_current_buf(), start_row, start_col) then
		start_col = 0
	end
	vim.api.nvim_win_set_cursor(0, { start_row + 1, start_col })
	vim.cmd("normal! v")
	vim.api.nvim_win_set_cursor(0, { end_row + 1, end_col })
end

local function SelectViaNodes(start_node, end_node)
	local start_row, start_col, _, _ = start_node:range()
	local _, _, end_row, end_col = end_node:range()
	SelectText(start_row, start_col, end_row, end_col)
end

local function GetFunctionNodes()
	local node = ts_utils.get_node_at_cursor()
	local start_node, path = FindParentNode(node, "function_declaration") -- Use your language's node name
    local end_node = start_node

	local declarations = {
		"method_definition",
		"method_declaration",
		"function_definition",
		"function_declaration",
		"constructor_definition",
		"constructor_declaration",
	}

	local start_node = find_parent_list(node, declarations)
    end_node = start_node

	if start_node == nil then
		local start_node, path = FindParentNode(node, "function_body") -- Use your language's node name
		if start_node ~= nil then
			end_node = start_node
			start_node = find_previous_siblings(start_node, {
				"function_declaration",
				"method_declaration",
				"method_signature",
			})
		end
	end

	if start_node == nil then
		local start_node, path = FindParentNode(node, "function_expression")
		if start_node ~= nil then
			end_node = start_node
			start_node, path = FindParentNode(end_node, "declaration")
		end
	end

	if start_node == nil then
		return nil, nil
	end

	start_node = find_previous_siblings(start_node, {
		"annotation",
		"decorator",
		"export_statement",
	})

    print(end_node:type())

    return start_node, end_node
end

local function SelectFunctionNode()
	local start_node, end_node = GetFunctionNodes()
	if start_node == nil or end_node == nil then
		return
	end
	SelectViaNodes(start_node, end_node)
end

local function GetInsideFunctionNodes()
	local node = ts_utils.get_node_at_cursor()
	local words = {
		"function_body",
		"constructor_declaration",
		"method_definition",
		"method_declaration",
		"function_declaration",
		"function_definition",
	}

	for _, word in ipairs(words) do
		local start_node = FindParentNode(node, word)
		if start_node ~= nil then
			print("found node", word)
			local child = find_child(start_node, "statement_block")
			if child ~= nil then
				return child, child
			end
			local child = find_child(start_node, "block")
			if child ~= nil then
				return child, child
			end
			return start_node, start_node
		end
	end
end

local function SelectInsideFunction()
	local start_node, end_node = GetInsideFunctionNodes()
	if start_node == nil or end_node == nil then
		return
	end
	local start_row, start_col, _, _ = start_node:range()
	local _, _, end_row, end_col = end_node:range()

	start_row, start_col, end_row, end_col = move_selection_based_on_curlys(start_row, start_col, end_row, end_col)
	SelectText(start_row, start_col, end_row, end_col)
end

vim.keymap.set("n", "vaf", function()
	SelectFunctionNode()
end, { desc = "Visual around function" })
vim.keymap.set("n", "yaf", function()
	SelectFunctionNode()
	vim.cmd("normal! y")
end, { desc = "Yank around function" })
vim.keymap.set("n", "daf", function()
	SelectFunctionNode()
	vim.cmd("normal! d")
end, { desc = "Delete around function" })
vim.keymap.set("n", "caf", function()
	SelectFunctionNode()
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("c<bs><esc>o", true, false, true), "n", false)
end, { desc = "Change around function" })

vim.keymap.set("n", "vif", function()
	SelectInsideFunction()
end, { desc = "Visual inside function" })
vim.keymap.set("n", "yif", function()
	SelectInsideFunction()
	vim.cmd("normal! y")
end, { desc = "Yank inside function" })
vim.keymap.set("n", "dif", function()
	SelectInsideFunction()
	vim.cmd("normal! d")
end, { desc = "Delete inside function" })
vim.keymap.set("n", "cif", function()
	SelectInsideFunction()
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("c<bs><esc>o", true, false, true), "n", false)
end, { desc = "Change inside function" })

vim.keymap.set("n", "<leader>id", function()
	TreeSitterIdentify()
end, { desc = "Identify current node" })
vim.keymap.set("n", "<leader>ic", function()
	TreeSitterIdentifyChildren()
end, { desc = "Identify children of current node" })
