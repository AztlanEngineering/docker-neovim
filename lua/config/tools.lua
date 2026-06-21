-- :ToolStatus — buffer-scoped tooling report (the :ALEInfo analogue).
--
-- Under the mount-cwd model it is NORMAL for project LSPs/formatters to be
-- absent in any given buffer (the tool may live above the mount, in another
-- project, on the host, or nowhere). So tooling state is PULLED on demand, not
-- pushed as notices. This command answers "what is my lsp/format/lint state for
-- THIS file right now, and where did each tool resolve from?"

local M = {}

-- Where did an executable resolve from? Tags the origin so "not at cwd" vs
-- "from the project" vs "baked" is visible.
local function origin(path)
  if not path or path == "" then
    return "not found"
  end
  if path:match("/%.venv/") or path:match("/site%-packages/") then
    return "project venv"
  end
  if path:match("/node_modules/") then
    return "project node_modules"
  end
  if path:match("^/x/") then
    return "mounted project"
  end
  if path:match("^/usr/local/bin/") or path:match("^/opt/") then
    return "baked (image)"
  end
  return path
end

local function resolve(bin)
  local p = vim.fn.exepath(bin)
  return p, origin(p)
end

function M.status(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local ft = vim.bo[bufnr].filetype
  local lines = {}
  local function add(s)
    lines[#lines + 1] = s
  end

  add(("# Tooling status — buffer %d  [filetype: %s]"):format(bufnr, ft ~= "" and ft or "none"))
  add("")

  -- LSP --------------------------------------------------------------------
  add("## LSP")
  local attached = vim.lsp.get_clients({ bufnr = bufnr })
  if #attached == 0 then
    add("  attached: (none)")
  else
    for _, c in ipairs(attached) do
      local cmd = type(c.config.cmd) == "table" and c.config.cmd[1] or "<fn>"
      local p, og = resolve(cmd)
      add(("  attached: %-16s  cmd=%s  [%s]"):format(c.name, p ~= "" and p or cmd, og))
    end
  end
  -- Configured-but-not-attached servers that match this filetype.
  local seen = {}
  for _, c in ipairs(attached) do
    seen[c.name] = true
  end
  local cfgs = vim.lsp.config and vim.lsp.config._configs or {}
  for name, cfg in pairs(type(cfgs) == "table" and cfgs or {}) do
    if not seen[name] and type(cfg) == "table" and cfg.filetypes then
      for _, f in ipairs(cfg.filetypes) do
        if f == ft then
          local cmd = type(cfg.cmd) == "table" and cfg.cmd[1] or nil
          local p, og = cmd and resolve(cmd) or { nil, "n/a" }, "n/a"
          add(("  configured (not attached): %-16s  [%s]"):format(name, cmd and origin(vim.fn.exepath(cmd)) or "no cmd"))
          break
        end
      end
    end
  end

  -- Formatters (conform) ---------------------------------------------------
  add("")
  add("## Formatters (conform)")
  local ok, conform = pcall(require, "conform")
  if not ok then
    add("  conform not loaded")
  else
    local fmts = conform.list_formatters_to_run(bufnr)
    if #fmts == 0 then
      add("  (none configured for this filetype)")
    end
    for _, f in ipairs(fmts) do
      local p = f.command and vim.fn.exepath(f.command) or ""
      add(("  %-22s %s  [%s]"):format(
        f.name,
        f.available and "available" or "NOT FOUND",
        f.available and origin(p) or "—"
      ))
    end
  end

  add("")
  add("## Format-on-save: " .. (vim.g._format_on_save_state ~= false and "ON" or "OFF"))

  vim.api.nvim_echo({ { table.concat(lines, "\n") } }, false, {})
end

function M.setup()
  vim.api.nvim_create_user_command("ToolStatus", function()
    M.status()
  end, { desc = "Tooling status (LSP/formatters) for the current buffer" })
end

return M
