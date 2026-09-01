---@type vim.lsp.Config
-- Bespoke server (no nvim-lspconfig counterpart), so it lives in plain lsp/.
-- The binary is host-built and bind-mounted by the launcher at /usr/local/bin
-- (glibc — runs natively in the glibc image, no gcompat).
return {
  -- A FUNCTION, not a table, for the same reason the preferLocal servers in
  -- lua/config/lsp.lua use one: the argv AND the spawn cwd are resolved per
  -- root_dir at spawn time, not once at startup.
  --
  -- SPAWN CWD IS THE WHOLE POINT. Neovim launches a server with cmd_cwd =
  -- NVIM's cwd (the mount root, /x), which is unrelated to the root_dir it
  -- computed below — and sem-lsp discovers its project from its OWN cwd:
  -- entry.rs calls `Project::discover_optional(&cwd)`, and sem-project's
  -- `resolve_config_path_from` only walks UP and deliberately ignores
  -- SEM_CONFIG_PATH. So whenever v3 is launched ABOVE the sem project
  -- (`cd ~/code/advl && v symbols/...` rather than from the project root),
  -- there is no manifest at or above /x, project_root is None, and entry.rs
  -- skips the store block entirely: the backend is built with NO GRAPH.
  --
  -- That failure is near-silent, which is why it survived: the LSP still
  -- ATTACHES (root_dir below resolves fine) and semantic tokens still paint,
  -- because they come off the parsed buffer. Only the graph-backed handlers —
  -- hover, definition, references — go quiet, reading exactly like "the graph
  -- didn't load". Measured 2026-08-31 on advl/symbols: from the repo root
  -- definition resolved; one directory up it returned {} with identical
  -- highlighting. Pinning SEM_CONFIG_PATH does NOT rescue it (that env layer
  -- is read by `find_project_root()`, which discover_optional never calls) —
  -- the cwd must actually be the root.
  cmd = function(dispatchers, config)
    local root = (config or {}).root_dir or vim.fn.getcwd()
    -- Prefer the launcher's DIRECTORY mount (name resolved at spawn time, so a
    -- host rename-swap reaches the next :LspRestart); the /usr/local/bin file
    -- mount is the fallback — it pins the container-start inode.
    local live = "/opt/hosttools/sem-lsp.d/sem-lsp"
    local bin = vim.uv.fs_stat(live) and live or "sem-lsp"
    -- `cmd_env` is IGNORED when cmd is a function, so the env rides here.
    return vim.lsp.rpc.start({ bin }, dispatchers, {
      cwd = root,
      env = {
        -- Directory form is canonical in sem-core (it wants a dir). Belt to the
        -- cwd's braces: the layers that DO read it (resolve_store_path via
        -- find_project_root) then agree with the cwd instead of being pinned to
        -- a /x that may not be the project.
        SEM_CONFIG_PATH = root,
        -- No kg daemon in the container; sem-lsp reads the store directly.
        SEM_DAEMON_AUTOSTART = "false",
        -- Deliberately NO SEM_STORE_PATH: sem-core derives {root}/.sem/lmdb
        -- itself, off the same root. Pinning it is redundant and a trap.
      },
    })
  end,
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
