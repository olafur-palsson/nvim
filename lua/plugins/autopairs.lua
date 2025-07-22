return {
	{
		"windwp/nvim-autopairs",
		config = function()
			require("nvim-autopairs").setup({
				-- global settings
				check_ts = true,
			})

			local npairs = require("nvim-autopairs")
			local Rule = require("nvim-autopairs.rule")

			-- C# specific: add [ ] pairing
			npairs.add_rules({
				Rule("[", "]", "cs"), -- use "cs" for C#
			})

			-- TypeScript: add < > for generics (only after identifier)
			npairs.add_rules({
				Rule("<", ">", "typescript"):with_pair(function(opts)
					local prev_char = opts.line:sub(opts.col - 1, opts.col - 1)
					return prev_char:match("[%w_)%.]")
				end),
			})
		end,
	},
}
