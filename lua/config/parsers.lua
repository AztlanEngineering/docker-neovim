-- SINGLE SOURCE OF TRUTH for the treesitter parser set.
--
-- Required by BOTH build/install-parsers.lua (the build-time bake) and
-- lua/plugins/treesitter.lua (runtime enable) so the baked set and the runtime
-- set cannot drift. Every entry is verified present in the nvim-treesitter
-- `main` parser registry at the pinned archive commit 4916d659.
--
-- 36 parsers, right-sized to the fleet's real languages: dropped
-- dart/go/haskell/hcl/jsonnet/svelte/terraform (no LSP/formatter/fleet use);
-- added nix (Nix-first fleet), css (cssls/stylelint), sparql (RDF sibling of
-- turtle), and the git family (Neogit). turtle kept (sem-lsp / RDF workflow).
return {
  "bash",
  "c",
  "css",
  "diff",
  "dockerfile",
  "git_config",
  "git_rebase",
  "gitattributes",
  "gitcommit",
  "gitignore",
  "graphql",
  "html",
  "javascript",
  "jsdoc",
  "json",
  "lua",
  "luadoc",
  "luap",
  "markdown",
  "markdown_inline",
  "nix",
  "printf",
  "python",
  "query",
  "regex",
  "rust",
  "scss",
  "sparql",
  "toml",
  "tsx",
  "turtle",
  "typescript",
  "vim",
  "vimdoc",
  "xml",
  "yaml",
}
