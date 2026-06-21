return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      spec = {
        { "<leader>f", group = "Find" }, -- snacks pickers
        { "<leader>h", group = "Git hunks" }, -- gitsigns
        { "<leader>l", group = "LSP/Tools" }, -- ToolStatus, inlay hints
        { "<leader>x", group = "Trouble" },
      },
    },
  },
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
  {
    "NvChad/nvim-colorizer.lua",
    event = "BufReadPre",
    opts = {
      filetypes = {
        'css',
        'scss',
        'javascript',
        'javascriptreact',
        'typescript',
        'typescriptreact',
        'html',
      },
      user_default_options = {
        mode = 'background',
        RRGGBBAA = true,
        rgb_fn = true,
        hsl_fn = true,
        css = true,
        css_fn = true,
      },
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    opts = {
      options = {
        theme = "iceberg_dark",
        section_separators = "",
        component_separators = "",
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = {
          "branch",
          -- Source diff counts from gitsigns (lualine's diff otherwise spawns
          -- its own `git diff` job and can disagree with the gutter).
          {
            "diff",
            source = function()
              local gs = vim.b.gitsigns_status_dict
              if gs then
                return { added = gs.added, modified = gs.changed, removed = gs.removed }
              end
            end,
          },
          "diagnostics",
        },
        lualine_c = { "filename" },
        lualine_x = {
          -- Show attached LSP server names
          {
            function()
              local clients = vim.lsp.get_clients({ bufnr = 0 })
              if #clients == 0 then return "" end
              local names = {}
              for _, c in ipairs(clients) do
                table.insert(names, c.name)
              end
              return table.concat(names, ", ")
            end,
            icon = " ",
          },
          "filetype",
        },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    },
  },
  -- File explorer is now snacks.explorer (see snacks.lua); neo-tree removed.
}
