return {
  { 'williamboman/mason.nvim', 
    config= true,
  },
  {
    'williamboman/mason-lspconfig.nvim',
    build=":MasonInstall",
    dependencies = { 
      'williamboman/mason.nvim',
      'neovim/nvim-lspconfig'
    },
    opts = {
      ensure_installed = {
        'bashls',
        'cssls',
        'eslint_d',
        'graphql',
        'lua_ls',
        'rust_analyzer',
        'somesass_ls',
        'stylelint_lsp',
        'shellcheck',
        'tsserver',
        'yamlls',
      },
      automatic_installation = true,
    }
  }
}
