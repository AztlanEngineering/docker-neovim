-- Options: static editor settings
-- Loaded before lazy.nvim in init.lua

vim.o.termguicolors = true

-- Indentation
vim.o.shiftwidth = 0       -- Use tabstop value
vim.o.softtabstop = -1     -- Use shiftwidth value
vim.o.expandtab = true     -- Convert tabs to spaces
vim.o.tabstop = 2          -- Width of a tab character

-- Folding (treesitter-based)
vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.foldlevel = 99       -- Start with all folds open

-- Display
vim.o.conceallevel = 0     -- Show all text without concealing
vim.o.number = true
vim.o.relativenumber = true
vim.o.numberwidth = 3
vim.o.signcolumn = "auto"
vim.o.cursorline = true
vim.o.cursorcolumn = true

-- Editing
vim.o.backspace = "indent,eol,start"

-- Clipboard: explicit OSC52 copy-only provider. The editor runs in a container
-- with no clipboard tool and no DISPLAY; OSC52 sends yanks to the host terminal
-- (foot) over the escape channel. Copy-only (paste reads the host via the
-- terminal's own paste); this avoids the unreliable provider auto-detection.
local osc52 = require("vim.ui.clipboard.osc52")
vim.g.clipboard = {
  name = "osc52",
  copy = {
    ["+"] = osc52.copy("+"),
    ["*"] = osc52.copy("*"),
  },
  paste = {
    ["+"] = function()
      return { vim.fn.getreg("", 1, 1), vim.fn.getregtype("") }
    end,
    ["*"] = function()
      return { vim.fn.getreg("", 1, 1), vim.fn.getregtype("") }
    end,
  },
}
