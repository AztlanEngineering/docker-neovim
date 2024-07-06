return {
  {
    "NeogitOrg/neogit",
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
  }
}
