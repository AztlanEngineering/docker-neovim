-- bootstrap lazy.nvim, LazyVim and your plugins
vim.g.mapleader = ","

require("config.options")
require("config.lazy")
require("config.autocmds")
require("config.keymaps")
