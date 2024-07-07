return {
  { "nvim-telescope/telescope.nvim",
    branch = '0.1.x',
    lazy = false,
    dependencies = "nvim-lua/plenary.nvim",
    keys = {
        { "<C-t>", "<CMD>Telescope<CR>", mode = { "n", "i", "v" } },
        { "=", "<CMD>Telescope find_files<CR>", mode = { "n", } },  -- Shortcut for finding files
        { ";", "<CMD>lua require('telescope.builtin').buffers({ sort_lastused = true })<CR>", mode = { "n", } },  -- Shortcut for searching buffers
        { "<C-l>", "<CMD>Telescope live_grep<CR>", mode = { "n", "i", "v" } },
        -- { "<C-c>", "<CMD>Telescope commands<CR>", mode = { "n", "i", "v" } },
        -- { "<C-k>", "<CMD>Telescope keymaps<CR>", mode = { "n", "i", "v" } },
        -- { "<C-s>", "<CMD>Telescope grep_string<CR>", mode = { "n", "i", "v" } },
    },
    config = true
  },
}
