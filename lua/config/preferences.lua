-- PERSONAL OVERRIDE LAYER — Adrian's deviations from the sane base.
--
-- Required LAST in init.lua, so these win by load order. This is the single
-- place personal taste lives; the base config (keymaps.lua, options.lua) stays
-- shareable/idiomatic. Comment out the require in init.lua to run base-only.
--
-- See df/session/NVIM/PREFERENCES.md for the rationale behind each line.

local map = vim.keymap.set

-- Movement model: ARROW KEYS move the cursor; bare hjkl switch panes/windows.
-- (The base put window-nav on <C-hjkl> and left hjkl as motion; here we move
-- pane-switching onto bare hjkl, which is the actual muscle memory.)
map("n", "h", "<C-w>h", { desc = "Window left" })
map("n", "j", "<C-w>j", { desc = "Window down" })
map("n", "k", "<C-w>k", { desc = "Window up" })
map("n", "l", "<C-w>l", { desc = "Window right" })

-- Pickers on the keys Adrian actually reaches for.
map("n", "=", function()
  Snacks.picker.files()
end, { desc = "Find files" })
map("n", ";", function()
  Snacks.picker.buffers({ sort_lastused = true })
end, { desc = "Buffers" })

-- <leader>e stays :e! (reload, discarding changes). Kept deliberately despite
-- sitting next to the save key — base already binds it; restated here so the
-- personal layer is self-documenting.
map("n", "<Leader>e", ":e!<CR>", { desc = "Reload file (discard changes)" })
