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
      -- WIRED MODULES (the disciplined list — do NOT let this sprawl).
      -- snacks is justified ONLY as the picker+explorer+input collapse
      -- (replaced telescope+fzf-native+neo-tree+nui+dressing). Everything else
      -- is explicitly OFF below so the boundary is visible in the config, not
      -- just in intention.
      bigfile = { enabled = true }, -- auto-degrade on huge files (cheap safety)
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

      -- DELIBERATELY OFF (host workflow covers these, or Cozette/--rm-hostile,
      -- or redundant). Flip on only with a reason.
      dashboard = { enabled = false }, -- v3 opens a file directly; no startup screen
      terminal = { enabled = false }, -- terminal mux is the host's job (tmux/sway)
      scroll = { enabled = false }, -- smooth scroll feels laggy over the boundary
      animate = { enabled = false },
      statuscolumn = { enabled = false }, -- lualine + gitsigns own the gutter
      indent = { enabled = false },
      scope = { enabled = false },
      words = { enabled = false }, -- revisit if symbol-occurrence highlight wanted
      zen = { enabled = false },
      dim = { enabled = false },
    },
  },
}
