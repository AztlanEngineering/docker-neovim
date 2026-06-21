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
  if path:match("^/usr/local/bin/") or path:match("^/usr/bin/") or path:match("^/opt/") then
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
  add("## LSP (attached)")
  local attached = vim.lsp.get_clients({ bufnr = bufnr })
  if #attached == 0 then
    add("  (none)")
  else
    for _, c in ipairs(attached) do
      -- cmd may be a table (resolve bin[1]) or a function (in-process / dynamic).
      local cmd = type(c.config.cmd) == "table" and c.config.cmd[1] or nil
      if cmd then
        local p, og = resolve(cmd)
        add(("  %-16s running  cmd=%s  [%s]"):format(c.name, p ~= "" and p or cmd, og))
      else
        add(("  %-16s running  cmd=<function>"):format(c.name))
      end
    end
  end

  -- Formatters (conform) ---------------------------------------------------
  -- list_formatters_for_buffer = all CONFIGURED for this ft (incl. unavailable),
  -- which is the question this tool answers ("why didn't biome run? -> NOT FOUND").
  -- list_formatters_to_run would hide the absent ones.
  add("")
  add("## Formatters (conform)")
  local ok, conform = pcall(require, "conform")
  if not ok then
    add("  conform not loaded")
  else
    local names = conform.list_formatters_for_buffer(bufnr) or {}
    if #names == 0 then
      add("  (none configured for this filetype)")
    end
    for _, name in ipairs(names) do
      local info = conform.get_formatter_info(name, bufnr)
      local builtin = not (info and info.command and info.command ~= name)
      local p = info and info.command and vim.fn.exepath(info.command) or ""
      local where
      if not info or not info.available then
        where = "NOT FOUND"
      elseif builtin and p == "" then
        where = "builtin"
      else
        where = origin(p)
      end
      add(("  %-22s %s  [%s]"):format(name, (info and info.available) and "available" or "absent", where))
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
