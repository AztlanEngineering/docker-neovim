-- Options: static editor settings
-- Loaded before config.plugins in init.lua

vim.o.termguicolors = true

-- Indentation
vim.o.shiftwidth = 0 -- Use tabstop value
vim.o.softtabstop = -1 -- Use shiftwidth value
vim.o.expandtab = true -- Convert tabs to spaces
vim.o.tabstop = 2 -- Width of a tab character

-- Folding (treesitter-based)
vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.foldlevel = 99 -- Start with all folds open

-- Display
vim.o.conceallevel = 0 -- Show all text without concealing
vim.o.number = true
vim.o.relativenumber = true
vim.o.numberwidth = 3
vim.o.signcolumn = "auto"
vim.o.cursorline = true
vim.o.cursorcolumn = true

-- Editing
vim.o.backspace = "indent,eol,start"

-- Persistence across --rm (project-local at /x/.nvim, which rides the cwd mount;
-- gitignore /x/.nvim in projects). Undo history + shada (marks, registers, search
-- + recent files for snacks.picker.recent / <leader>fr) survive container exit.
-- Falls back to the in-container state dir when /x isn't writable (no project).
local state = (vim.fn.filewritable("/x") == 2) and "/x/.nvim" or (vim.fn.stdpath("state") .. "/persist")
vim.fn.mkdir(state .. "/undo", "p")
vim.o.undofile = true
vim.o.undodir = state .. "/undo"
vim.o.shadafile = state .. "/shada"

-- Clipboard: OSC52 (the only channel that crosses container -> host tmux -> foot).
--  * COPY works through tmux (needs `set-clipboard on` + `allow-passthrough on`
--    in the host tmux.conf — see docs/LAUNCHER.md).
--  * PASTE: tmux does NOT forward the OSC52 read-response into the container, so
--    "+p can't pull the host clipboard through tmux. paste reads nvim's own
--    register; use the terminal's paste (Ctrl+Shift+V) for host->editor.
--  * SMART: a TextYankPost autocmd mirrors only real YANKS (not deletes) to "+",
--    so `y` reaches the host clipboard WITHOUT clipboard=unnamedplus routing every
--    d/x through the slow OSC52 channel.
local osc52 = require("vim.ui.clipboard.osc52")
vim.g.clipboard = {
  name = "osc52",
  copy = { ["+"] = osc52.copy("+"), ["*"] = osc52.copy("*") },
  paste = {
    ["+"] = function()
      return { vim.fn.getreg("", 1, 1), vim.fn.getregtype("") }
    end,
    ["*"] = function()
      return { vim.fn.getreg("", 1, 1), vim.fn.getregtype("") }
    end,
  },
}
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("user.clip", { clear = true }),
  callback = function()
    if vim.v.event.operator == "y" and vim.v.event.regname == "" then
      vim.fn.setreg("+", vim.v.event.regcontents, vim.v.event.regtype)
    end
  end,
})
