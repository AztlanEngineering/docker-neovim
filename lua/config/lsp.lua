-- Native LSP activation (Neovim 0.12 lsp/ idiom). Required from init.lua AFTER
-- config.plugins, so nvim-lspconfig's lsp/ data is on the runtimepath first.
--
-- Servers with NO file in lsp/ or after/lsp/ are configured entirely by
-- nvim-lspconfig's shipped lsp/<name>.lua data. Overrides live in after/lsp/
-- (plugin lsp/ data would otherwise win on key conflicts); the one bespoke
-- server (sem_lsp) lives in plain lsp/.

-- Turtle/RDF: nvim's .ttl detection otherwise yields 'teraterm' for comment-first
-- files (it even ships syntax/teraterm.vim). Force turtle for every .ttl.
vim.filetype.add({ extension = { ttl = "turtle" } })

-- :ToolStatus — on-demand "what LSP/formatter state do I have for this buffer,
-- and where did each tool resolve from?" (the :ALEInfo analogue). Under
-- mount-cwd it is normal for project tools to be absent; status is pulled, not
-- pushed as notices.
require("config.tools").setup()
vim.keymap.set("n", "<leader>li", "<cmd>ToolStatus<cr>", { desc = "Tooling status (LSP/format)" })

-- Advertise blink.cmp's completion capabilities to EVERY server. '*' is the
-- lowest-priority layer; per-server (and after/lsp/) configs merge on top.
-- pcall keeps the headless Docker build pass working if blink isn't loadable yet.
local ok, blink = pcall(require, "blink.cmp")
if ok then
  vim.lsp.config("*", { capabilities = blink.get_lsp_capabilities() })
end

-- Diagnostics. 0.11+ defaults virtual_text OFF; without this the editor shows
-- almost nothing. jump.float=true keeps the core [d/]d jumps showing the float.
vim.diagnostic.config({
  virtual_text = { current_line = true, source = "if_many" },
  severity_sort = true,
  float = { border = "rounded", source = true },
  jump = { float = true },
})

-- Put the project venv's bin on PATH BEFORE the executable() guards below, so a
-- venv-provided ruff is found. (autocmds.lua also does this, but it loads AFTER
-- config.lsp in init.lua — the guards would miss it. Doing it here makes the
-- ordering self-contained.) Idempotent if autocmds repeats it.
local venv = os.getenv("VIRTUAL_ENV")
if venv and not (":" .. vim.env.PATH .. ":"):find(":" .. venv .. "/bin:", 1, true) then
  vim.env.PATH = venv .. "/bin:" .. vim.env.PATH
end

-- Activate servers. Tool SOURCE model (glibc image — host glibc binaries run):
--   BAKED in image (always available): lua_ls (tarball), basedpyright, ts_ls,
--     bashls, yamlls, jsonls, html, cssls (npm).
--   GUARDED (enable only when the binary resolves on PATH):
--     rust_analyzer (host-tool: v3 mounts it from the host when present; also
--       needs rustc for its root_dir, so guard on both -> bare .rs never errors),
--     ruff (project venv), sem_lsp (host-built bind-mount).
vim.lsp.enable({
  "lua_ls", -- tarball
  "bashls",
  "cssls",
  "jsonls",
  "html",
  "ts_ls",
  "yamlls", -- npm
  "basedpyright", -- python types (always-on, baked)
})

-- Guarded servers: no binary -> not enabled -> no spawn error.
-- rust_analyzer is a host-tool (not baked); its lspconfig config also calls
-- `rustc --print sysroot`, so require both before enabling.
if vim.fn.executable("rust-analyzer") == 1 and vim.fn.executable("rustc") == 1 then
  vim.lsp.enable("rust_analyzer")
end
-- ruff = project-pinned lint/format from the venv; not baked. venv-less project
-- just gets no ruff (basedpyright still provides types).
if vim.fn.executable("ruff") == 1 then
  vim.lsp.enable("ruff")
end
-- sem_lsp = host-built Turtle/RDF server, bind-mounted by the launcher.
if vim.fn.executable("sem-lsp") == 1 then
  vim.lsp.enable("sem_lsp")
end

-- LspAttach: ONLY the delta over 0.11/0.12 defaults. Defaults already ship
-- grn/grr/gri/gra/grt/grx/gO/K/<C-s>/[d/]d/<C-w>d and document_color (0.12).
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("user.lsp", { clear = true }),
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
    local function map(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buffer = args.buf, desc = desc })
    end

    map("gd", vim.lsp.buf.definition, "Go to definition")
    map("gD", vim.lsp.buf.declaration, "Go to declaration")
    map("<leader>lh", function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = args.buf }), { bufnr = args.buf })
    end, "Toggle inlay hints")

    -- Paired-tag/identifier rename for html + ts (0.12). Filter takes client_id only.
    if client:supports_method("textDocument/linkedEditingRange") then
      vim.lsp.linked_editing_range.enable(true, { client_id = client.id })
    end

    -- ruff complements basedpyright (lint/format); its hover is noise next to
    -- basedpyright's type hover. Let basedpyright own K.
    if client.name == "ruff" then
      client.server_capabilities.hoverProvider = false
    end
  end,
})
