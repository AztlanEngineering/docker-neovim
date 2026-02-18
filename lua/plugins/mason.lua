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

-- LSP servers installed via Mason (npm-based, work on musl/Alpine)
local servers = {
  'bashls',
  'cssls',
  'graphql',
  'somesass_ls',
  'stylelint_lsp',
  'ts_ls',
  'yamlls',
}

-- LSP servers installed via apk (glibc binaries don't work on musl)
-- These are configured via lspconfig but NOT managed by Mason
local system_servers = {
  'lua_ls',
  'rust_analyzer',
}

return {
  {
    'mason-org/mason.nvim',
    opts = {
      PATH = "append",
    },
    config = function(_, opts)
      require('mason').setup(opts)

      -- Command to install all packages (for headless Docker builds)
      vim.api.nvim_create_user_command("MasonInstallAllPackages", function()
        local package_cmd = table.concat(packages, " ")
        vim.cmd("MasonInstall " .. package_cmd)
        vim.notify("Installing all specified packages: " .. package_cmd, vim.log.levels.INFO)
      end, {
        desc = "Install all Mason packages specified in the config.",
        nargs = 0,
      })

      -- Command to install all LSP servers (for headless Docker builds)
      vim.api.nvim_create_user_command("MasonInstallAllLsps", function()
        local lspconfig_to_package = require("mason-lspconfig").get_mappings().lspconfig_to_package

        local package_args = {}
        for _, server in ipairs(servers) do
          local mason_name = lspconfig_to_package[server]
          if mason_name then
            table.insert(package_args, mason_name)
          else
            table.insert(package_args, server)
          end
        end

        local package_cmd = table.concat(package_args, " ")
        vim.cmd("MasonInstall " .. package_cmd)
        vim.notify("Installing all specified LSP servers: " .. package_cmd, vim.log.levels.INFO)
      end, {
        desc = "Install all LSP servers specified in the config.",
        nargs = 0,
      })
    end,
  },
  {
    'mason-org/mason-lspconfig.nvim',
    dependencies = {
      'mason-org/mason.nvim',
      'neovim/nvim-lspconfig',
    },
    opts = {
      ensure_installed = servers,
      automatic_enable = true,
    },
  },
}
