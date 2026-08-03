---@type vim.lsp.Config
-- Bespoke server (no nvim-lspconfig counterpart), so it lives in plain lsp/.
-- The binary is host-built and bind-mounted by the launcher at /usr/local/bin
-- (glibc — runs natively in the glibc image, no gcompat).
return {
  -- Prefer the launcher's DIRECTORY mount (name resolved at spawn time, so a
  -- host rename-swap reaches the next :LspRestart); the /usr/local/bin file
  -- mount is the fallback — it pins the container-start inode.
  cmd = (function()
    local live = "/opt/hosttools/sem-lsp.d/sem-lsp"
    if vim.uv.fs_stat(live) then
      return { live }
    end
    return { "sem-lsp" }
  end)(),
  cmd_env = {
    -- Directory form is canonical in sem-core (it wants a dir). WORKDIR is /x,
    -- but a :cd inside nvim would change the spawn cwd, so pin it.
    SEM_CONFIG_PATH = "/x",
    -- No kg daemon in the container; sem-lsp reads the store directly.
    SEM_DAEMON_AUTOSTART = "false",
    -- Deliberately NO SEM_STORE_PATH: sem-core derives {root}/.kg/lmdb itself.
    -- Pinning it is redundant today and a trap the day APP_NAME flips .kg->.sem.
  },
  filetypes = { "turtle" },
  -- Prefer the workspace manifest, then a bare sem.toml. Listing the workspace
  -- manifest first fixes the bug where sem-lsp never attached at the workspace
  -- root (which has only sem.workspace.toml).
  root_dir = function(bufnr, on_dir)
    local root = vim.fs.root(bufnr, { "sem.workspace.toml", "sem.toml" })
    if root then
      on_dir(root)
    end
  end,
  -- No syntax='' trick: treesitter (turtle parser, baked) + LSP semantic tokens
  -- (priority 125 > treesitter 100) layer correctly on their own.
}
