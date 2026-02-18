-- sem-lsp: Turtle/RDF language server
-- Binary is mounted into the container at /usr/local/bin/sem-lsp
-- via the v2() function in df/config/zsh/aliases.sh

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
      filetypes = { "turtle" },
      root_dir = lspconfig.util.find_git_ancestor,
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
