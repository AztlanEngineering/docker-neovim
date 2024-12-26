-- Define package lists
local packages = {
  'stylua',
  'shellcheck',
  'flake8',
  'pylint',
  'mypy',
  'jsonlint',
  'yamllint',
}

local servers = {
  'bashls',
  'cssls',
  'graphql',
  'lua_ls',
  'rust_analyzer',
  'somesass_ls',
  'stylelint_lsp',
  'ts_ls',
  'yamlls',
}

return {
  {
    'williamboman/mason.nvim',
    config = true,
    opts = {
      ensure_installed = packages,
      PATH = "append",
    }
  },
  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = {
      'williamboman/mason.nvim',
      'neovim/nvim-lspconfig'
    },
    config = function()
      require('mason-lspconfig').setup({
        ensure_installed = servers,
      })

      -- Command to install all packages
      vim.api.nvim_create_user_command("MasonInstallAllPackages", function()
        -- Convert packages to command argument format
        local package_cmd = table.concat(packages, " ")

        -- Install all packages in one go
        vim.cmd("MasonInstall " .. package_cmd)

        vim.notify("Installed all specified packages: " .. package_cmd, vim.log.levels.INFO)
      end, {
        desc = "Install all Mason packages specified in the config.",
        nargs = 0,
      })

      -- Command to install all LSP servers
      vim.api.nvim_create_user_command("MasonInstallAllLsps", function()
        local lspconfig_to_package = require("mason-lspconfig.mappings.server").lspconfig_to_package

        local package_args = {}

        for _, server in ipairs(servers) do
          local server_name = lspconfig_to_package[server]
          if server_name then
            table.insert(package_args, server_name)
          end
        end

        -- Convert packages to command argument format
        local package_cmd = table.concat(package_args, " ")

        -- Install all LSP servers in one go
        vim.cmd("MasonInstall " .. package_cmd)

        vim.notify("Installed all specified LSP servers: " .. package_cmd, vim.log.levels.INFO)
      end, {
        desc = "Install all LSP servers specified in the config.",
        nargs = 0,
      })
    end,
  },
}

