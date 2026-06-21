-- bootstrap lazy.nvim, LazyVim and your plugins
vim.g.mapleader = ","

require("config.options")
require("config.plugins") -- vim.pack plugin layer (native 0.12; was config.lazy)
require("config.lsp") -- native LSP activation (after plugins, so lsp/ data is on rtp)
require("config.autocmds")
require("config.keymaps")
-- Personal override layer, LAST so it wins. Comment out to run base-only.
require("config.preferences")
