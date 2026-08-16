---@type vim.lsp.Config
-- TypeScript 7 (the native Go line, 2026-08-16): there is no tsserver — the
-- compiler binary itself speaks LSP (`tsc --lsp --stdio`). Lives in plain lsp/
-- (same rule as sem_lsp) so the image never depends on the bundled
-- nvim-lspconfig rev shipping lsp/tsgo.lua. Registry entry: `typescript` in
-- lsp-servers.json (vendored from df). preferLocal is false there on purpose:
-- a project-local OLD typescript has no --lsp and would silently kill the
-- server; the baked daemon reads the project's tsconfig anyway.
return {
  cmd = { "tsc", "--lsp", "--stdio" },
  filetypes = {
    "javascript", "javascriptreact", "javascript.jsx",
    "typescript", "typescriptreact", "typescript.tsx",
  },
  root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
}
