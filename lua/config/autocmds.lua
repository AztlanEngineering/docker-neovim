-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
local function augroup(name)
  return vim.api.nvim_create_augroup("lazyvim_user_" .. name, { clear = true })
end


-- Enable syntax highlighting
-- vim.cmd('syntax on') -- always on
vim.cmd("set termguicolors")

-- Width of the signcolumn
vim.o.signcolumn = "auto"
vim.api.nvim_create_autocmd('BufWinEnter', {
  group = augroup('MyAutoCmds'),
  callback = function()
    vim.wo.signcolumn = "auto" 
  end
})

-- Use 'shiftwidth' value as 'tabstop'
vim.o.shiftwidth = 0

-- Use 'shiftwidth' value for 'softtabstop'
vim.o.softtabstop = -1

-- Convert tabs to spaces
vim.o.expandtab = true

-- Set the width of a tab character
vim.o.tabstop = 2
vim.bo.tabstop = 2

-- Enable syntax-based code folding
vim.o.foldmethod = 'syntax'

-- Start with all folds open
vim.o.foldlevel = 99

-- Display all text, without concealing
vim.o.conceallevel = 0

-- Show line numbers and relative line numbers
vim.o.number = true
vim.o.relativenumber = true

-- Set the width of the line number column
vim.o.numberwidth = 3

-- Enable normal backspace behavior (across indent, end of line, start of insert)
vim.o.backspace = 'indent,eol,start'

-- Highlight the line and column of the cursor position
vim.o.cursorline = true
vim.o.cursorcolumn = true

-- Set the leader key to ','
vim.g.mapleader = ","

local function setup_venv_path()
  local venv_path = os.getenv("VIRTUAL_ENV")
  if venv_path then
    local venv_bin = venv_path .. "/bin"
    vim.env.PATH = venv_bin .. ":" .. vim.env.PATH
  end
end

setup_venv_path()
