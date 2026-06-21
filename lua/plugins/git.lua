-- Git: gitsigns ONLY. In-editor git = see + navigate + stage/reset/preview hunks
-- + inline blame. Full git (commit/push/branch-diff/log/rebase) happens on the
-- HOST (tmux/shell/gh), where identity + credentials live — the --rm container
-- has neither, so an in-editor porcelain fought the sandbox. Neogit + diffview
-- dropped deliberately.
return {
  {
    "lewis6991/gitsigns.nvim",
    event = "VeryLazy",
    opts = {
      on_attach = function(bufnr)
        local gs = require("gitsigns")
        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
        end

        -- Hunk navigation (]c / [c, with a diff-mode fallback to native ]c/[c).
        map("n", "]c", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            gs.nav_hunk("next")
          end
        end, "Next hunk")
        map("n", "[c", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            gs.nav_hunk("prev")
          end
        end, "Prev hunk")

        -- Hunk actions under <leader>h (which-key "git hunks" group).
        map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
        map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
        map("v", "<leader>hs", function()
          gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "Stage selection")
        map("v", "<leader>hr", function()
          gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "Reset selection")
        map("n", "<leader>hS", gs.stage_buffer, "Stage buffer")
        map("n", "<leader>hu", gs.undo_stage_hunk, "Undo stage hunk")
        map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
        map("n", "<leader>hb", function()
          gs.blame_line({ full = true })
        end, "Blame line")
        map("n", "<leader>hB", gs.toggle_current_line_blame, "Toggle line blame")
        map("n", "<leader>hd", gs.diffthis, "Diff this")
        map("n", "<leader>hq", function()
          gs.setqflist("all")
        end, "Hunks -> quickfix (all)")

        -- Hunk text object (ih) for operators/visual.
        map({ "o", "x" }, "ih", gs.select_hunk, "Select hunk")
      end,
    },
  },
}
