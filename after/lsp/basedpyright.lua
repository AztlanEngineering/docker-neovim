---@type vim.lsp.Config
-- Override of nvim-lspconfig's shipped lsp/basedpyright.lua (after/lsp/ for the
-- same precedence reason as lua_ls). basedpyright is the always-on Python type
-- server (baked); ruff (project venv, guarded) layers lint/format on top.
return {
  settings = {
    basedpyright = {
      analysis = { typeCheckingMode = "standard" },
    },
    python = {
      -- The launcher mounts the project venv and prepends $VIRTUAL_ENV/bin to
      -- PATH (autocmds.lua). On glibc the venv's python runs natively. Use it
      -- when present; fall back to the image python3.
      pythonPath = (os.getenv("VIRTUAL_ENV") and os.getenv("VIRTUAL_ENV") .. "/bin/python") or "python3",
    },
  },
}
