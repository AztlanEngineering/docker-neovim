-- Autocmds and runtime setup

local function augroup(name)
  return vim.api.nvim_create_augroup("lazyvim_user_" .. name, { clear = true })
end

-- Reset signcolumn on each new window
vim.api.nvim_create_autocmd("BufWinEnter", {
  group = augroup("MyAutoCmds"),
  callback = function()
    vim.wo.signcolumn = "auto"
  end,
})

-- Prepend virtualenv bin to PATH if active
local function setup_venv_path()
  local venv_path = os.getenv("VIRTUAL_ENV")
  if venv_path then
    local venv_bin = venv_path .. "/bin"
    vim.env.PATH = venv_bin .. ":" .. vim.env.PATH
  end
end

setup_venv_path()
