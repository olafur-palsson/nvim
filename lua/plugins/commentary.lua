return {
	{
		"tpope/vim-commentary",
		config = function()
			vim.keymap.set("n", "<C-/>", "gcc")
		end,
	},
}
