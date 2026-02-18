-- sem-lsp: Turtle/RDF language server
-- The sem-lsp binary is volume-mounted into the container
-- via the v2() function in df/config/zsh/aliases.sh.
--
-- The LMDB store is project-local at .kg/lmdb/ inside the project directory
-- (APP_NAME is still "kg" during the v2 transition).
-- Since the project is mounted at /x/, the store is automatically available
-- at /x/.kg/lmdb/ -- no separate mount needed.
--
-- sem-lsp gracefully degrades: when sem.toml or the LMDB store is missing
-- it runs in syntax-only mode (no completions/hover/graph diagnostics)
-- and shows a warning to the editor via window/showMessage.
-- Daemon autostart is disabled; sem-lsp reads directly from the project store.

-- Register .ttl as turtle filetype (neovim doesn't know it by default)
vim.filetype.add({
  extension = {
    ttl = "turtle",
  },
})

local configs = require("lspconfig.configs")
local lspconfig = require("lspconfig")

if not configs.sem_lsp then
  configs.sem_lsp = {
    default_config = {
      cmd = { "/usr/local/bin/sem-lsp" },
      cmd_env = {
        -- Tell sem-lsp where sem.toml is (project always mounted at /x/)
        SEM_CONFIG_PATH = "/x/sem.toml",
        -- Project-local store: APP_NAME is still "kg" during v2 transition
        SEM_STORE_PATH = "/x/.kg/lmdb",
        -- No daemon needed; sem-lsp reads directly from the project store
        SEM_DAEMON_AUTOSTART = "false",
      },
      filetypes = { "turtle" },
      -- Only require a sem.toml project; sem-lsp will gracefully degrade
      -- to syntax-only mode if sem.toml is missing.
      root_dir = function(fname)
        return lspconfig.util.root_pattern("sem.toml")(fname)
      end,
      single_file_support = false,
      settings = {},
    },
  }
end

return {
  {
    "neovim/nvim-lspconfig",
    opts = function()
      -- Only start sem-lsp if the binary is present (volume-mounted at runtime)
      if vim.fn.executable("sem-lsp") == 1 then
        lspconfig.sem_lsp.setup({
          on_attach = function(client, bufnr)
            -- Disable regex-based syntax highlighting when sem-lsp semantic
            -- tokens are available — they provide richer, graph-aware colouring.
            if client.server_capabilities.semanticTokensProvider then
              vim.bo[bufnr].syntax = ""
            end
          end,
        })
      end
    end,
  },
}
