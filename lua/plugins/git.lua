return {
  {
    "NeogitOrg/neogit",
    event = "VeryLazy",
    dependencies = {
      "nvim-lua/plenary.nvim",         -- required
      "sindrets/diffview.nvim",        -- optional - Diff integration
      "nvim-telescope/telescope.nvim", -- optional
    },
    config = true,
    keys = {
      { "<leader>G", "<CMD>Neogit<CR>", mode = { "n", "v" } },
      { "<leader>D", "<CMD>DiffviewOpen<CR>", mode = { "n", "v" } },
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    event = "VeryLazy",
    config = true,
  }
}
