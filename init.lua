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

-- df theme layer ([nvim-theme], df docs/notes/nvim-theme.md): the launcher
-- mounts the rendered palette fragment at /df-theme.lua when the df checkout
-- has one. VERY LAST on purpose — plugins (devicons, lualine) DERIVE colors
-- from the highlight state at setup, so applying the fragment any earlier
-- changes what they derive and breaks the lossless contract (caught by df
-- tools/nvim-theme-check, which diffs the full state with/without the mount).
-- Absent mount (off-fleet, plain docker run): pcall fails silently → baked
-- iceberg.
pcall(dofile, "/df-theme.lua")
