-- sem-lsp: Turtle/RDF language server
-- The sem-lsp binary is volume-mounted into the container
-- via the v2() function in df/config/zsh/aliases.sh.
--
-- The LMDB store is project-local at .sem/lmdb/ inside the project directory.
-- Since the project is mounted at /x/, the store is automatically available
-- at /x/.sem/lmdb/ -- no separate mount needed.
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
        -- No daemon needed; sem-lsp reads from the project-local .sem/lmdb/ store
        SEM_DAEMON_AUTOSTART = "false",
      },
      filetypes = { "turtle" },
      root_dir = function(fname)
        return lspconfig.util.root_pattern("sem.toml")(fname)
          or lspconfig.util.find_git_ancestor(fname)
      end,
      single_file_support = true,
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
        lspconfig.sem_lsp.setup({})
      end
    end,
  },
}
