-- Keymaps — SANE BASE LAYER.
--
-- This file is idiomatic, unsurprising defaults: hjkl move the cursor, = and ;
-- keep their vim meaning, pickers live under <leader>. Adrian's personal
-- deviations (hjkl=panes, ==files, ;=buffers, <leader>e=:e!) are applied on top
-- by lua/config/preferences.lua, which is required LAST in init.lua. Keep this
-- file shareable; put preferences there, not here.

local map = vim.keymap.set

-- Window navigation: Ctrl+hjkl (the base convention). hjkl stay as motions.
map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })

-- Splits
map("n", "<Leader>v", "<C-w>v", { desc = "Split vertical" })
map("n", "<Leader>s", "<C-w>s", { desc = "Split horizontal" })

-- Pickers (snacks). Base lives under <leader>; personal =/; in preferences.lua.
map("n", "<Leader>ff", function() Snacks.picker.files() end, { desc = "Find files" })
map("n", "<Leader>fg", function() Snacks.picker.grep() end, { desc = "Grep" })
map("n", "<Leader>fb", function() Snacks.picker.buffers() end, { desc = "Buffers" })
map("n", "<Leader>fr", function() Snacks.picker.recent() end, { desc = "Recent files" })
map("n", "<Leader>n", function() Snacks.explorer() end, { desc = "File explorer" })

-- Grep word under cursor (replaces the <leader>w search/replace dance, kept too)
map("n", "<Leader>W", ":%s/<C-r><C-w>/", { desc = "Replace word under cursor (file)" })
map("n", "<Leader>w", function() Snacks.picker.grep_word() end, { desc = "Grep word under cursor" })

-- File ops
map("n", "<Leader>e", ":e!<CR>", { desc = "Reload file (discard changes)" })
map("n", "<Leader><Space>", ":w<CR>", { desc = "Save file" })

-- Comment toggle on <Leader>/ (kept muscle memory), via native gc (0.10+;
-- nvim-comment plugin removed). gcc/gc operators also work natively.
map("n", "<Leader>/", "gcc", { remap = true, desc = "Toggle comment" })
map("x", "<Leader>/", "gc", { remap = true, desc = "Toggle comment" })

-- Exit terminal mode
map("t", "<Esc>", "<C-\\><C-n>", { silent = true, desc = "Exit terminal mode" })

-- Diagnostics. [d/]d are core defaults since 0.10; <leader>xd floats.
-- (jump float is configured globally in lua/plugins/lsp.lua.)
map("n", "<Leader>xd", vim.diagnostic.open_float, { desc = "Diagnostic float" })
