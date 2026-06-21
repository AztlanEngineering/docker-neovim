-- nvim-lspconfig is DATA-ONLY in 2026: it ships lsp/<server>.lua config tables
-- consumed by vim.lsp.config/enable (driven from lua/config/lsp.lua). 0.12 ships
-- the mechanism, not the ~400 server config tables — those still live here.
-- No framework code on the load path; eager so the lsp/ data is on the rtp
-- before the first FileType. lazy-lock.json pins it like every other plugin.
return {
  { "neovim/nvim-lspconfig", lazy = false },
}
