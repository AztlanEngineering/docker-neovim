-- Autocmds and runtime setup.
--
-- (The venv PATH-prepend that used to live here moved to config.lsp, which runs
-- earlier in init.lua and needs the venv on PATH before its executable() guards.
-- The old BufWinEnter signcolumn='auto' reset was removed: signcolumn is set
-- globally in options.lua and the reset only caused gutter-shift flicker.)

-- Reflect yanked text briefly (0.12 idiom).
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("user.yank", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})
