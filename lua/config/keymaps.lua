-- Keymaps

local map = vim.keymap.set

-- Window navigation
map("n", "j", "<C-W><C-J>", { desc = "Window down" })
map("n", "k", "<C-W><C-K>", { desc = "Window up" })
map("n", "l", "<C-W><C-L>", { desc = "Window right" })
map("n", "h", "<C-W><C-H>", { desc = "Window left" })

-- Search/replace word under cursor
map("n", "<Leader>W", ":%s/<C-r><C-w>/", { desc = "Replace word under cursor (file)" })
map("n", "<Leader>w", "/<C-r><C-w>", { desc = "Search word under cursor" })

-- Backspace deletes char and enters insert
map("n", "<bs>", "Xi", { desc = "Delete char left and insert" })

-- Split windows
map("n", "<Leader>v", "<C-W>v", { desc = "Split vertical" })
map("n", "<Leader>s", "<C-W>s", { desc = "Split horizontal" })

-- Reload file
map("n", "<Leader>e", ":e!<CR>", { desc = "Reload file" })

-- Save file
map("n", "<Leader><Space>", ":w<CR>", { desc = "Save file" })

-- Exit terminal mode
map("t", "<Esc>", "<C-\\><C-n>", { silent = true, desc = "Exit terminal mode" })

-- Diagnostic navigation
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "<leader>xd", vim.diagnostic.open_float, { desc = "Diagnostic float" })
