-- TidalCycles bridge — the editor half of [tidal-rig] L3/L4 (canonical spec:
-- df docs/notes/tidal-rig.md; AV-439/440). vim-tidal sends code to the HOST
-- rig (df tools/tidal tmux session, window "repl") through the socket the
-- launcher mounts on `v3 --tidal`. Without that mount a send fails loudly in
-- :messages — no guard needed, and non-tidal buffers pay nothing.

-- Send target: the df rig, not the plugin's ":0.1" default. socket_name
-- "default" resolves to /tmp/tmux-1000/default in-container — exactly where
-- bin/lib/tidal.sh mounts the host's socket dir.
vim.g.tidal_target = "tmux"
vim.g.tidal_default_config = { socket_name = "default", target_pane = "tidal:repl" }
-- Explicit maps below (the L4 rule: ours, not plugin defaults).
vim.g.tidal_no_mappings = 1

vim.api.nvim_create_autocmd("FileType", {
  pattern = "tidal",
  group = vim.api.nvim_create_augroup("df_tidal", { clear = true }),
  callback = function(ev)
    -- vim-tidal's ftplugin sets no 'commentstring', which leaves the builtin
    -- gcc/gc dead on .tidal buffers. Tidal is Haskell: -- line comments.
    vim.bo[ev.buf].commentstring = "-- %s"
    local function bmap(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, remap = true, silent = true, desc = desc })
    end
    -- The core live-coding gesture: eval the paragraph (= one pattern block).
    bmap("n", "<C-e>", "<Plug>TidalParagraphSend", "Tidal: eval paragraph")
    bmap("v", "<C-e>", "<Plug>TidalRegionSend", "Tidal: eval selection")
    -- One-letter set (collision-checked vs keymaps/preferences: all free;
    -- buffer-local anyway, so .tidal buffers are the only place these exist).
    bmap("n", "<Leader>l", "<Plug>TidalLineSend", "Tidal: eval line")
    -- ,1..,9 silence that stream directly — mirrors d1..d9.
    for i = 1, 9 do
      bmap("n", "<Leader>" .. i, "<cmd>TidalSilence " .. i .. "<cr>", "Tidal: silence d" .. i)
    end
    -- Local hush for flow only (,0 = the whole board, ,h = the word) — the
    -- GLOBAL panic path is sway's $mod+Ctrl+m → `tidal hush` (spec rule 2).
    bmap("n", "<Leader>0", "<cmd>TidalHush<cr>", "Tidal: hush")
    bmap("n", "<Leader>h", "<cmd>TidalHush<cr>", "Tidal: hush")
  end,
})
