return {
	{
		'ThePrimeagen/harpoon',
		config = function()
			require('harpoon').setup({
				tabline = true
			})
			local harpoon_mark = require('harpoon.mark')
			local harpoon_ui = require('harpoon.ui')


            vim.keymap.set("n", "<Leader>sp", function() 
                vim.cmd("vsp")
                vim.cmd("vertical resize 60")
                harpoon_ui.nav_next()
            end)
			vim.keymap.set('n', '<leader>a', function() 
				harpoon_mark.add_file()
			end, { desc = "Harpoon Add"})
			vim.keymap.set('n', '<leader>hn', function() 
				harpoon_ui.toggle_quick_menu()
			end, { desc = "Harpoon Quick Menu"})
			vim.keymap.set('n', '<leader>hh', function() 
				harpoon_ui.nav_prev()
			end, { desc = "Harpoon Previous"})
			vim.keymap.set('n', '<leader>ht', function() 
				harpoon_ui.nav_next()
			end, { desc = "Harpoon next"})
			vim.keymap.set('n', '<leader>ha', function() 
				harpoon_ui.nav_file(1)
			end, { desc = "Harpoon 1"})
			vim.keymap.set('n', '<leader>ho', function() 
				harpoon_ui.nav_file(2)
			end, { desc = "Harpoon 2"})
			vim.keymap.set('n', '<leader>he', function() 
				harpoon_ui.nav_file(3)
			end, { desc = "Harpoon 3"})
			vim.keymap.set('n', '<leader>hu', function() 
				harpoon_ui.nav_file(4)
			end, { desc = "Harpoon 4"})
		end
	}
}
