---@type vim.lsp.Config
-- Override of nvim-lspconfig's shipped lsp/lua_ls.lua. MUST live in after/lsp/
-- (plugin lsp/ data sits later on the rtp than user lsp/ and would otherwise
-- win on key conflicts; after/lsp/ has the final say).
return {
  -- lua_ls defaults to writing its generated meta/ + log INTO its install dir
  -- (/opt/lua-language-server, root-owned) — fails as uid 1000 ("Permission
  -- denied") and the server never attaches. Redirect both to a writable cache
  -- dir. (A baked warm-cache was tried and reverted: lua_ls --check didn't
  -- reliably materialize meta at build time, and an empty --metapath stops
  -- attach entirely — the LSP-attach build assertion caught it. The ~4.5s
  -- first-index per --rm is accepted; revisit if it bites.)
  cmd = {
    "lua-language-server",
    "--metapath=" .. vim.fn.stdpath("cache") .. "/lua-language-server/meta",
    "--logpath=" .. vim.fn.stdpath("cache") .. "/lua-language-server/log",
  },
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      telemetry = { enable = false },
    },
  },
}
