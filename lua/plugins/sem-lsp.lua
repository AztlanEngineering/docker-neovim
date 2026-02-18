-- sem-lsp: Turtle/RDF language server
-- Binary is mounted into the container at /usr/local/bin/sem-lsp
-- via the v2() function in df/config/zsh/aliases.sh
--
-- Requires: host daemon running + ~/.kg/store mounted read-only into container.
-- The v2() shell function should include:
--   -v "$HOME/.kg/store:/home/myuser/.kg/store:ro"

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
        -- Daemon runs on host; container reads LMDB store via volume mount
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
