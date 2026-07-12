-- df-check — headless toolchain probe, run by `v3 --check` (mounted, not baked).
-- For the cwd-mounted project: opens one representative file per filetype
-- (or the files given on the command line), waits for LSP attach, and prints
-- every LSP + conform formatter with its resolved ORIGIN, then exits.
--
-- Origin taxonomy (the typed-mounts model — v3 DECLARES its decisions via env,
-- classification never guesses from paths alone):
--   project = resolved under /x (the repo's own node_modules/.bin etc.)
--   venv    = resolved under $VIRTUAL_ENV (the project's Python env)
--   host    = basename listed in $V3_ORIGIN_HOST_TOOLS (per-tool ro bind-mounts)
--   baked   = anything else (pinned into the image = editor infrastructure)

local host_tools = {}
for t in (vim.env.V3_ORIGIN_HOST_TOOLS or ""):gmatch("%S+") do
  host_tools[t] = true
end
local venv = vim.env.VIRTUAL_ENV

local function origin(path)
  if not path or path == "" then return "builtin" end
  if host_tools[vim.fs.basename(path)] then return "host" end
  if venv and venv ~= "" and path:sub(1, #venv) == venv then return "venv" end
  if path:find("^/x/") then return "project" end
  return "baked"
end

-- LSP client name -> binary name, where they differ (for cmd-less fallback).
local lsp_bin = {
  ts_ls = "typescript-language-server",
  lua_ls = "lua-language-server",
  basedpyright = "basedpyright-langserver",
  bashls = "bash-language-server",
  rust_analyzer = "rust-analyzer",
  sem_lsp = "sem-lsp",
  jsonls = "vscode-json-language-server",
  cssls = "vscode-css-language-server",
  html = "vscode-html-language-server",
  eslint = "vscode-eslint-language-server",
}

local function respath(cmd, name)
  if type(cmd) == "table" then cmd = cmd[1] end
  if type(cmd) == "string" and cmd ~= "" then
    if cmd:find("/") then return cmd end
    local p = vim.fn.exepath(cmd)
    if p ~= "" then return p end
  end
  -- cmd was a function/unresolvable: fall back to the client's known binary
  if name then
    local p = vim.fn.exepath(lsp_bin[name] or name)
    if p ~= "" then return p end
  end
  return nil
end

-- Representative files: explicit args win; else first hit per extension,
-- pruning dependency/build trees so the find stays fast on monorepos.
local exts = { "ts", "tsx", "js", "py", "lua", "sh", "json", "rs", "md", "css" }
-- LSP-attach wait budget per filetype (don't burn 4s on LSP-less filetypes).
local wait_ms = {
  typescript = 6000, typescriptreact = 6000, javascript = 6000,
  python = 6000, lua = 6000, rust = 6000,
}

local files = {}
for _, f in ipairs(vim.fn.argv()) do table.insert(files, f) end
if #files == 0 then
  for _, e in ipairs(exts) do
    local cmd = ("find /x -maxdepth 6 \\( -name node_modules -o -name .git "
    .. "-o -name .bun -o -name target -o -name dist -o -name .venv "
    .. "-o -name build \\) -prune -o -type f -name '*.%s' -print -quit 2>/dev/null"):format(e)
    local r = vim.fn.systemlist(cmd)
    if r[1] and r[1] ~= "" then table.insert(files, r[1]) end
  end
end

local out = {}
local function say(s) table.insert(out, s) end

say(("df-check · %s · venv=%s · host-tools=[%s]"):format(
  vim.env.NVIM_IMAGE or "image:?", venv or "none",
  vim.env.V3_ORIGIN_HOST_TOOLS or ""))
say(("origin legend: project=/x · venv=$VIRTUAL_ENV · host=declared mount · baked=in-image"))
say("")

if #files == 0 then
  say("no probe files found under /x — is the cwd the repo root?")
end

for _, f in ipairs(files) do
  vim.cmd.edit(vim.fn.fnameescape(f))
  local buf = vim.api.nvim_get_current_buf()
  local ft = vim.bo[buf].filetype
  local budget = wait_ms[ft] or 800
  vim.wait(budget, function()
    return #vim.lsp.get_clients({ bufnr = buf }) > 0
  end, 100)

  local lsps = {}
  for _, c in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
    table.insert(lsps, ("%s[%s]"):format(c.name, origin(respath(c.config.cmd, c.name))))
  end

  local fmts = {}
  local ok, conform = pcall(require, "conform")
  if ok then
    for _, name in ipairs(conform.list_formatters_for_buffer(buf) or {}) do
      local info = conform.get_formatter_info(name, buf)
      if info.available then
        -- info.command may be a bare name (e.g. "ruff"): resolve via PATH
        -- (which includes $VIRTUAL_ENV/bin) before classifying, or the venv
        -- tool would misreport as baked.
        table.insert(fmts, ("%s[%s]"):format(name, origin(respath(info.command))))
      else
        table.insert(fmts, name .. "[NOT FOUND]")
      end
    end
  end

  say(("%-44s %-14s lsp: %-34s fmt: %s"):format(
    (f:gsub("^/x/", "")), ft ~= "" and ft or "?",
    #lsps > 0 and table.concat(lsps, " ") or "none",
    #fmts > 0 and table.concat(fmts, " ") or "none"))
end

io.stdout:write(table.concat(out, "\n") .. "\n")
vim.cmd("qa!")
