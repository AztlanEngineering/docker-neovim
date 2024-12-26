return {
  {
    "dense-analysis/ale",
    event = {
      "BufReadPre",
      "BufNewFile",
    },
    config = function()
      -- Enable ALE fix on save
      vim.g.ale_fix_on_save = 1

      -- Define linters for specific filetypes
      vim.g.ale_linters = {
        javascript = {"eslint", "biome"},
        javascriptreact = {"eslint", "biome"},
        scss = {"stylelint"},
        typescript = {"eslint", "tsserver", "biome"},
        typescriptreact = {"eslint", "tsserver", "biome"},
      }

      -- Define fixers for specific filetypes
      vim.g.ale_fixers = {
        javascript = {"eslint", "biome"},
        javascriptreact = {"eslint", "biome"},
        scss = {"stylelint"},
        html = {"prettier", "biome"},
        typescript = {"prettier", "eslint", "biome"},
        typescriptreact = {"prettier", "eslint", "biome"},
        yaml = {"yamlfix"},
        python = {"black", "isort"},
      }

      -- Set ALE linter aliases
      vim.g.ale_linter_aliases = {
        jsx = "javascript",
      }

      -- Set ALE sign symbols
      vim.g.ale_sign_error = "●"
      vim.g.ale_sign_warning = "—"

      -- Enable ALE linting on file open
      vim.g.ale_lint_on_enter = 1

      -- Enable ALE integration with airline
      vim.g.airline_extensions_ale_enabled = 1

      -- Enable ALE completion
      vim.g.ale_completion_enabled = 1

      -- Enable ALE TypeScript Prettier local config usage
      vim.g.ale_typescript_prettier_use_local_config = 1

      -- Enable ALE Biome global usage
      vim.g.ale_biome_use_global = 1

      -- Set indentLine character for easier processing
      vim.g.indentLine_char_list = {"|"}

      -- Set key mappings for ALE commands
      local opts = { noremap = true, silent = true }
      vim.api.nvim_set_keymap("n", "<leader>f", ":ALEFix<CR>", opts)
      vim.api.nvim_set_keymap("n", "<leader>a", ":ALEToggleBuffer<CR>", opts)
      vim.api.nvim_set_keymap("n", "<leader>z", ":ALEPrevious<CR>", opts)
      vim.api.nvim_set_keymap("n", "<leader>x", ":ALENext<CR>", opts)
      vim.api.nvim_set_keymap("n", "<leader>d", ":ALEGoToDefinition<CR>", opts)
      vim.api.nvim_set_keymap("n", "<leader>D", ":ALEGoToTypeDefinition<CR>", opts)
      vim.api.nvim_set_keymap("n", "<leader>c", ":ALEStopAllLSPs<CR>", opts)
    end,
  },
}
