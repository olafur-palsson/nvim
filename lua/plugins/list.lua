return {
    -- Comments
    { "folke/todo-comments.nvim", opts = {} },

    -- Status line
    { "nvim-lualine/lualine.nvim" },

    -- Telescope
    { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },

    -- LSP
    { "neoclide/coc.nvim", branch = "release" },
}
