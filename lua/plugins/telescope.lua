return {
  { "nvim-telescope/telescope.nvim",
    lazy = false,
    dependencies = {
      { "nvim-lua/plenary.nvim" },
      { 'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make'
    }
    },

    keys = {
        { "<C-t>", "<CMD>Telescope<CR>", mode = { "n", "i", "v" } },
        { "=", "<CMD>lua require('telescope.builtin').find_files({ cwd = '/x' })<CR>", mode = { "n", } },  -- Shortcut for finding files in the current directory
        -- { "=", "<CMD>lua require('telescope.builtin').find_files({ cwd = vim.fn.expand('%:p:h') })<CR>", mode = { "n", } },  -- Shortcut for finding files in the current directory
        { ";", "<CMD>lua require('telescope.builtin').buffers({ sort_lastused = true })<CR>", mode = { "n", } },  -- Shortcut for searching buffers
        { "<C-l>", "<CMD>Telescope live_grep<CR>", mode = { "n", "i", "v" } },
        { "<leader>ll", ':lua require("telescope.builtin").find_files({ cwd = vim.fn.stdpath("log") })<CR>', mode = { "n" } },
        -- { "<C-c>", "<CMD>Telescope commands<CR>", mode = { "n", "i", "v" } },
        -- { "<C-k>", "<CMD>Telescope keymaps<CR>", mode = { "n", "i", "v" } },
        -- { "<C-s>", "<CMD>Telescope grep_string<CR>", mode = { "n", "i", "v" } },
    },
    config = function()
      local telescope = require("telescope")
      local telescopeConfig = require("telescope.config")
      
      -- Clone the default Telescope configuration
      local vimgrep_arguments = { unpack(telescopeConfig.values.vimgrep_arguments) }
      
      -- I want to search in hidden/dot files.
      table.insert(vimgrep_arguments, "--hidden")
      -- I don't want to search in the `.git` directory.
      table.insert(vimgrep_arguments, "--glob")
      table.insert(vimgrep_arguments, "!**/.git/*")
      table.insert(vimgrep_arguments, "--glob")
      table.insert(vimgrep_arguments, "!**/node_modules/*")
      table.insert(vimgrep_arguments, "--glob")
      table.insert(vimgrep_arguments, "!**/.terraform/*")
      require("telescope").setup {
        extensions = {
          fzf = {
            fuzzy = true,                    -- false will only do exact matching
            override_generic_sorter = true,  -- override the generic sorter
            override_file_sorter = true,     -- override the file sorter
            case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
                                             -- the default case_mode is "smart_case"
          }
        },
        defaults = {
		      vimgrep_arguments = vimgrep_arguments,
        },
        pickers = {
	      	find_files = {
	      		-- `hidden = true` will still show the inside of `.git/` as it's not `.gitignore`d.
	      		find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" , "--glob", "!**/node_modules/*", "--glob", "!**/.terraform/*" },
	      	},
	      },
      }
      require('telescope').load_extension('fzf')
    end,
  },
}
