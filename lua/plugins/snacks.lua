-- snacks.nvim — the UI-primitives layer.
--
-- Adopted as a deliberate suite (not just a finder swap): it replaces telescope
-- (picker), neo-tree (explorer), and dressing (input + select). Pure Lua, no
-- build step and no binary — a good fit for the baked --rm image (telescope's
-- fzf-native needed a `make` C build).
--
-- Keymaps live in the config layer, NOT here: base picker/grep/explorer keys in
-- lua/config/keymaps.lua, personal overrides (=/;/<leader>n) in preferences.lua.
-- This spec only provides the engines + their behavior.
--
-- Note (decided): frecency / recent-files history is NOT persisted — under --rm
-- its sqlite state would reset each session anyway. Revisit in the persistence
-- phase if cross-session memory is wanted.

-- Ripgrep behavior migrated from the old telescope config:
--   * search hidden/dot files
--   * respect .gitignore (ignored = false)
--   * always exclude .git, node_modules, .terraform
local rg_exclude = { ".git", "node_modules", ".terraform" }

return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = { enabled = true },
      input = { enabled = true }, -- replaces dressing's vim.ui.input
      notifier = { enabled = true }, -- notifications + LSP progress surface
      picker = {
        enabled = true,
        sources = {
          files = { hidden = true, ignored = false, exclude = rg_exclude },
          grep = { hidden = true, ignored = false, exclude = rg_exclude },
          -- explorer: show dotfiles, hide gitignored (matches old neo-tree)
          explorer = { hidden = true, ignored = false },
        },
      },
    },
  },
}
