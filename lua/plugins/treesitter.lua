return {
  {
    "nvim-treesitter/nvim-treesitter",
    -- Archived upstream 2026-04-03; kept deliberately for its query corpus.
    -- branch guards against a default-branch change (the config uses the
    -- main-only API); commit + lazy-lock.json are the reproducibility pins.
    branch = "main",
    commit = "4916d6592ede8c07973490d9322f187e07dfefac", -- final main HEAD; repo read-only
    lazy = false, -- upstream: "This plugin does not support lazy-loading."
    -- No build hook: parsers are baked at image-build time by
    -- build/install-parsers.lua (synchronous). +TSUpdate was async and a no-op.
    config = function()
      require("nvim-treesitter").setup()

      -- Parsers are baked into the image. As a safety net for non-image use
      -- (e.g. a host run), install the source-of-truth set only if missing —
      -- in the baked image this branch never fires, so there is no per-launch
      -- recompile (the bug this whole workstream removes).
      if #vim.api.nvim_get_runtime_file("parser/lua.so", false) == 0 then
        require("nvim-treesitter").install(require("config.parsers"))
      end

      -- Highlighting: enable for every filetype that has a baked parser.
      -- pcall no-ops for filetypes without one (== config.parsers).
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(ev)
          pcall(vim.treesitter.start, ev.buf)
        end,
      })

      -- Indentation is experimental upstream and worse than a good ftplugin for
      -- most languages (get_indent returns -1 with no indents query, which Vim
      -- treats as "keep indent", NOT "fall back to ftplugin"). Enable it only
      -- where there is no decent ftplugin indent AND the parser carries the `I`
      -- (indents) flag: turtle, sparql, graphql, scss.
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "turtle", "sparql", "graphql", "scss" },
        callback = function(ev)
          vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },
}
