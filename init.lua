-- bootstrap: vim.pack plugins + config modules
vim.g.mapleader = ","

require("config.options")
require("config.plugins") -- vim.pack plugin layer (native 0.12; was config.lazy)
require("config.lsp") -- native LSP activation (after plugins, so lsp/ data is on rtp)
require("config.autocmds")
require("config.keymaps")
require("config.tidal") -- [tidal-rig] L3/L4: vim-tidal target + ft-local maps
-- Personal override layer, LAST so it wins. Comment out to run base-only.
require("config.preferences")
