return {
  {
    "cocopon/iceberg.vim",
    config = function()
      vim.cmd("colorscheme iceberg")
      vim.api.nvim_set_hl(0, 'Normal', { bg = 'none' })
      vim.api.nvim_set_hl(0, 'NormalNC', { bg = 'none' })
      vim.api.nvim_set_hl(0, 'SignColumn', { bg = 'none' })
      vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'none' })
      vim.api.nvim_set_hl(0, 'VertSplit', { bg = 'none' })
      vim.api.nvim_set_hl(0, 'EndOfBuffer', { bg = 'none' })
      vim.api.nvim_set_hl(0, 'TabLineFill', { bg = 'none' })
    end,
  },
  -- {
  --   "LazyVim/LazyVim",
  --   opts = {
  --     colorscheme = "iceberg",
  --   },
  -- },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "kyazdani42/nvim-web-devicons", opt = true },
    event = "VeryLazy",
    opts = {
      options = {
        theme = "iceberg_dark",
        section_separators = "",
        component_separators = "",
      },
    }
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
      -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
    },
    opts = {
      close_if_last_window = true,
      popup_border_style = "rounded",
      sort_case_insensitive = true,
      enable_git_status = true,
      filesystem = {
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          hide_gitignored = true,
        },
      },
    },
    -- config = function()
      -- vim.fn.sign_define("DiagnosticSignError", {text = " ", texthl = "DiagnosticSignError"})
      -- vim.fn.sign_define("DiagnosticSignWarn", {text = " ", texthl = "DiagnosticSignWarn"})
      -- vim.fn.sign_define("DiagnosticSignInfo", {text = " ", texthl = "DiagnosticSignInfo"})
      -- vim.fn.sign_define("DiagnosticSignHint", {text = "󰌵", texthl = "DiagnosticSignHint"})
    -- end,
    keys = {
      { "<Leader>n", "<CMD>Neotree toggle<CR>", mode = { "n", "i", "v" } },
    },
  },
}
