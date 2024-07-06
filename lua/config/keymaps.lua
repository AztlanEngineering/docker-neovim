-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- init.lua or keymaps.lua (wherever you define your key mappings)

vim.g.mapleader = ","

-- Normal mode key mappings
vim.api.nvim_set_keymap('n', 'j', '<C-W><C-J>', { noremap = true })
vim.api.nvim_set_keymap('n', 'k', '<C-W><C-K>', { noremap = true })
vim.api.nvim_set_keymap('n', 'l', '<C-W><C-L>', { noremap = true })
vim.api.nvim_set_keymap('n', 'h', '<C-W><C-H>', { noremap = true })

vim.api.nvim_set_keymap('n', 'K', ':ALEHover<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', 'gr', ':ALEFindReferences<CR>', { noremap = true, silent = true })

vim.api.nvim_set_keymap('n', '<Leader>W', ':%s/<C-r><C-w>/', { noremap = true })
vim.api.nvim_set_keymap('n', '<Leader>w', '/<C-r><C-w>', { noremap = true })
vim.api.nvim_set_keymap('n', '<Leader>q', ':%s/<C-r><C-w>/', { noremap = true })

-- Split windows
vim.api.nvim_set_keymap('n', '<Leader>v', '<C-W>v', { noremap = true })
vim.api.nvim_set_keymap('n', '<Leader>s', '<C-W>s', { noremap = true })

-- Reload file
vim.api.nvim_set_keymap('n', '<Leader>e', ':e!<CR>', { noremap = true })

-- Toggle line number
-- vim.api.nvim_set_keymap('n', '<Leader>l', ':set number!<CR>', { noremap = true })
-- vim.api.nvim_set_keymap('n', '<Leader>L', ':set relativenumber!<CR>', { noremap = true })

-- ALE commands
-- vim.api.nvim_set_keymap('n', '<Leader>f', ':ALEFix<CR>', { noremap = true })
-- vim.api.nvim_set_keymap('n', '<Leader>a', ':ALEToggleBuffer<CR>', { noremap = true })
-- vim.api.nvim_set_keymap('n', '<Leader>z', ':ALEPrevious<CR>', { noremap = true })
-- vim.api.nvim_set_keymap('n', '<Leader>x', ':ALENext<CR>', { noremap = true })
-- vim.api.nvim_set_keymap('n', '<Leader>d', ':ALEGoToDefinition<CR>', { noremap = true })
-- vim.api.nvim_set_keymap('n', '<Leader>D', ':ALEGoToTypeDefinition<CR>', { noremap = true })
-- vim.api.nvim_set_keymap('n', '<Leader>c', ':ALEStopAllLSPs<CR>', { noremap = true })

-- Toggle Indent Lines
vim.api.nvim_set_keymap('n', '<Leader>y', ':IndentLinesToggle<CR>', { noremap = true })

-- Save file
vim.api.nvim_set_keymap('n', '<Leader><Space>', ':w<CR>', { noremap = true })
