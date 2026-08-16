---@type vim.lsp.Config
-- TypeScript 7 (the native Go line, 2026-08-16): there is no tsserver — the
-- compiler binary itself speaks LSP (`tsc --lsp --stdio`). Override of
-- nvim-lspconfig's shipped lsp/tsgo.lua (after/lsp/ for the same precedence
-- reason as lua_ls): the plugin's cmd is a resolver function that wants a
-- `tsgo` binary; npm typescript@7 ships only bin/tsc, so the plugin's config
-- silently never attached (measured 2026-08-16 in-image). Registry entry:
-- `typescript` in lsp-servers.json (vendored from df). preferLocal is false
-- there on purpose: a project-local OLD typescript has no --lsp and would
-- silently kill the server; the baked daemon reads the project's tsconfig
-- anyway.
return {
  cmd = { "tsc", "--lsp", "--stdio" },
  filetypes = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescriptreact",
    "typescript.tsx",
  },
  root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
}
