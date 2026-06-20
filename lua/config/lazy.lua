local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    -- add LazyVim and import its plugins
    -- { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    -- import/override with your plugins
    { import = "plugins" },
  },
  defaults = {
    -- Baked image: everything loads at startup (one-shot per file-open). Honest
    -- eager default; per-spec event/cmd gates still apply where declared.
    lazy = false,
    -- Pinning is done by the committed lazy-lock.json; version is only the
    -- resolution fallback for `Lazy update`. Do NOT set "*" — it would float
    -- un-tagged plugins (snacks, treesitter main) and fight the lockfile.
    version = false,
  },
  install = { colorscheme = { "iceberg", "habamax" } }, -- iceberg is the theme; tokyonight isn't installed
  checker = { enabled = false }, -- disabled: plugins are baked + digest-pinned
  rocks = { enabled = false }, -- no plugin uses a rockspec; drops the lua5.1/luarocks apk set
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        -- "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
