-- lua/config/plugins.lua
-- Native Neovim 0.12 vim.pack plugin layer. Replaces lazy.nvim + lua/plugins/*.lua.
--
-- MODEL (verified against :h vim.pack, 0.12.3):
--  * vim.pack.add() is imperative + BLOCKING: clones every missing plugin in
--    parallel and returns only once all are on disk. No :wait() needed (the
--    treesitter PARSER bake is a separate headless step, build/install-parsers.lua).
--  * Reproducibility = the committed nvim-pack-lock.json. On the first add() the
--    locked revision wins over `version` (which is only the resolution fallback).
--  * confirm=false: REQUIRED for the headless Docker build (default true blocks on
--    a y/n prompt under --headless).
--  * load=true: baked eager image; source plugin/ + ftdetect/ immediately so
--    trouble's :Trouble command (a plugin/ script, not setup()) exists. We still
--    call setup() explicitly for every plugin below.
--  * NO dependency resolution: every repo is listed explicitly (deps included).
--  * NO build hooks remain (blink fuzzy=lua; treesitter parsers baked separately).

local ai = require("config.ai")

-- rtp builtins lazy.nvim disabled via performance.rtp.disabled_plugins. vim.pack
-- has no equivalent; replicate with loaded_* guards, set BEFORE builtins load.
-- (matchit/matchparen/netrw left ENABLED, as in the old lazy.lua.)
vim.g.loaded_gzip = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_tar = 1
vim.g.loaded_zipPlugin = 1
vim.g.loaded_zip = 1
vim.g.loaded_tutor_mode_plugin = 1
vim.g.loaded_2html_plugin = 1 -- tohtml

-- Spec list. Commit pins live in nvim-pack-lock.json (authoritative); `version`
-- here is the resolution fallback used to (re)generate the lock.
local specs = {
  { src = "https://github.com/saghen/blink.cmp", version = vim.version.range("1") },
  { src = "https://github.com/neovim/nvim-lspconfig" },
  { src = "https://github.com/folke/snacks.nvim" },
  {
    src = "https://github.com/nvim-treesitter/nvim-treesitter",
    version = "4916d6592ede8c07973490d9322f187e07dfefac", -- archived final main HEAD
  },
  { src = "https://github.com/stevearc/conform.nvim" },
  { src = "https://github.com/windwp/nvim-autopairs" },
  { src = "https://github.com/lewis6991/gitsigns.nvim" },
  { src = "https://github.com/folke/which-key.nvim" },
  { src = "https://github.com/cocopon/iceberg.vim" },
  { src = "https://github.com/catgoose/nvim-colorizer.lua" },
  { src = "https://github.com/nvim-lualine/lualine.nvim" },
  { src = "https://github.com/nvim-tree/nvim-web-devicons" }, -- lualine dep (no auto-resolve)
  { src = "https://github.com/folke/trouble.nvim" },
}

-- Copilot is the single gated AI surface (lua/config/ai.lua). Adds the backend +
-- the blink source repo only when enabled.
if ai.enable_copilot then
  table.insert(specs, { src = "https://github.com/zbirenbaum/copilot.lua" })
  table.insert(specs, { src = "https://github.com/giuxtaposition/blink-cmp-copilot" })
end

-- Install (blocking) + load. confirm=false for headless; load=true sources
-- plugin/ scripts (trouble's :Trouble). setup() is still called per-plugin below.
vim.pack.add(specs, { confirm = false, load = true })

-- Colorscheme first, then the transparent-bg overrides.
vim.cmd("colorscheme iceberg")
for _, g in ipairs({ "Normal", "NormalNC", "SignColumn", "NormalFloat", "VertSplit", "EndOfBuffer", "TabLineFill" }) do
  vim.api.nvim_set_hl(0, g, { bg = "none" })
end

require("nvim-web-devicons").setup()

-- blink.cmp -----------------------------------------------------------------
do
  local default_sources = { "lsp", "path", "snippets", "buffer" }
  local providers = {}
  if ai.enable_copilot then
    table.insert(default_sources, "copilot")
    providers.copilot = { name = "copilot", module = "blink-cmp-copilot", score_offset = 100, async = true }
  end
  require("blink.cmp").setup({
    keymap = { preset = "enter" },
    appearance = { nerd_font_variant = "normal", kind_icons = nil },
    completion = {
      menu = { draw = { columns = { { "label", "label_description", gap = 1 }, { "kind" } } } },
      documentation = { auto_show = true },
      ghost_text = { enabled = false },
    },
    sources = { default = default_sources, providers = providers },
    snippets = { preset = "default" },
    fuzzy = { implementation = "lua" },
    signature = { enabled = true },
  })
end

-- copilot.lua (backend only; the menu source surfaces it) -------------------
if ai.enable_copilot then
  require("copilot").setup({
    suggestion = { enabled = false },
    panel = { enabled = false },
  })
end

-- snacks.nvim (disciplined module list — see PLAN-DECISIONS #6) --------------
do
  local rg_exclude = { ".git", "node_modules", ".terraform" }
  require("snacks").setup({
    bigfile = { enabled = true },
    input = { enabled = true },
    notifier = { enabled = true },
    picker = {
      enabled = true,
      sources = {
        files = { hidden = true, ignored = false, exclude = rg_exclude },
        grep = { hidden = true, ignored = false, exclude = rg_exclude },
        explorer = { hidden = true, ignored = false },
      },
    },
    dashboard = { enabled = false },
    terminal = { enabled = false },
    scroll = { enabled = false },
    animate = { enabled = false },
    statuscolumn = { enabled = false },
    indent = { enabled = false },
    scope = { enabled = false },
    words = { enabled = false },
    zen = { enabled = false },
    dim = { enabled = false },
  })
end

-- conform.nvim --------------------------------------------------------------
do
  local format_on_save = true
  local format_disabled_bufs = {}
  require("conform").setup({
    -- Tool SOURCE model (glibc): PROJECT tools resolve from the mounted env via
    -- prefer_local upward-search (biome/prettier); EDITOR tools baked (stylua/shfmt);
    -- ruff from the project venv. Missing tool -> conform skips gracefully.
    formatters_by_ft = {
      lua = { "stylua" },
      sh = { "shfmt" },
      python = { "ruff_organize_imports", "ruff_format" },
      javascript = { "biome" },
      javascriptreact = { "biome" },
      typescript = { "biome" },
      typescriptreact = { "biome" },
      json = { "biome" },
      jsonc = { "biome" },
      css = { "biome" },
      scss = { "biome" },
      markdown = { "prettier" },
      html = { "prettier" },
      ["_"] = { "trim_whitespace" },
    },
    formatters = {
      biome = { prefer_local = "node_modules/.bin" },
      prettier = { prefer_local = "node_modules/.bin" },
    },
    format_on_save = function(bufnr)
      if not format_on_save or format_disabled_bufs[bufnr] then
        return
      end
      return { timeout_ms = 1000, lsp_format = "fallback" }
    end,
  })
  -- Publish format-on-save state so :ToolStatus (config.tools) can read it.
  vim.g.format_on_save_enabled = true
  vim.api.nvim_create_user_command("FormatToggle", function()
    format_on_save = not format_on_save
    vim.g.format_on_save_enabled = format_on_save
    vim.notify("Format on save: " .. (format_on_save and "ON" or "OFF"))
  end, { desc = "Toggle format-on-save globally" })
  vim.api.nvim_create_user_command("FormatToggleBuf", function()
    local bufnr = vim.api.nvim_get_current_buf()
    format_disabled_bufs[bufnr] = not format_disabled_bufs[bufnr]
    vim.notify("Format on save (buffer): " .. (format_disabled_bufs[bufnr] and "OFF" or "ON"))
  end, { desc = "Toggle format-on-save for current buffer" })
  vim.keymap.set("n", "<leader>f", function()
    require("conform").format({ async = true })
  end, { desc = "Format buffer" })
  vim.keymap.set("n", "<leader>F", "<cmd>FormatToggle<cr>", { desc = "Toggle format-on-save" })
end

require("nvim-autopairs").setup({})

-- gitsigns ------------------------------------------------------------------
require("gitsigns").setup({
  on_attach = function(bufnr)
    local gs = require("gitsigns")
    local function map(mode, l, r, desc)
      vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
    end
    map("n", "]c", function()
      if vim.wo.diff then
        vim.cmd.normal({ "]c", bang = true })
      else
        gs.nav_hunk("next")
      end
    end, "Next hunk")
    map("n", "[c", function()
      if vim.wo.diff then
        vim.cmd.normal({ "[c", bang = true })
      else
        gs.nav_hunk("prev")
      end
    end, "Prev hunk")
    map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
    map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
    map("v", "<leader>hs", function()
      gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
    end, "Stage selection")
    map("v", "<leader>hr", function()
      gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
    end, "Reset selection")
    map("n", "<leader>hS", gs.stage_buffer, "Stage buffer")
    map("n", "<leader>hu", gs.undo_stage_hunk, "Undo stage hunk")
    map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
    map("n", "<leader>hb", function()
      gs.blame_line({ full = true })
    end, "Blame line")
    map("n", "<leader>hB", gs.toggle_current_line_blame, "Toggle line blame")
    map("n", "<leader>hd", gs.diffthis, "Diff this")
    map("n", "<leader>hq", function()
      gs.setqflist("all")
    end, "Hunks -> quickfix (all)")
    map({ "o", "x" }, "ih", gs.select_hunk, "Select hunk")
  end,
})

-- which-key -----------------------------------------------------------------
require("which-key").setup({
  spec = {
    { "<leader>f", group = "Find" },
    { "<leader>h", group = "Git hunks" },
    { "<leader>l", group = "LSP/Tools" },
    { "<leader>x", group = "Trouble" },
  },
})

-- nvim-colorizer (maintained catgoose fork) ---------------------------------
require("colorizer").setup({
  filetypes = { "css", "scss", "javascript", "javascriptreact", "typescript", "typescriptreact", "html" },
  user_default_options = {
    mode = "background",
    RRGGBBAA = true,
    rgb_fn = true,
    hsl_fn = true,
    css = true,
    css_fn = true,
  },
})

-- lualine -------------------------------------------------------------------
require("lualine").setup({
  options = { theme = "iceberg_dark", section_separators = "", component_separators = "" },
  sections = {
    lualine_a = { "mode" },
    lualine_b = {
      "branch",
      {
        "diff",
        source = function()
          local gs = vim.b.gitsigns_status_dict
          if gs then
            return { added = gs.added, modified = gs.changed, removed = gs.removed }
          end
        end,
      },
      "diagnostics",
    },
    lualine_c = { "filename" },
    lualine_x = {
      {
        function()
          local clients = vim.lsp.get_clients({ bufnr = 0 })
          if #clients == 0 then
            return ""
          end
          local names = {}
          for _, c in ipairs(clients) do
            table.insert(names, c.name)
          end
          return table.concat(names, ", ")
        end,
        icon = " ",
      },
      "filetype",
    },
    lualine_y = { "progress" },
    lualine_z = { "location" },
  },
})

-- trouble (commands from plugin/, sourced via load=true; keymaps unconditional)
require("trouble").setup({})
for _, m in ipairs({
  { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", "Diagnostics (Trouble)" },
  { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", "Buffer Diagnostics (Trouble)" },
  { "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>", "Symbols (Trouble)" },
  { "<leader>cl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", "LSP refs (Trouble)" },
  { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", "Location List (Trouble)" },
  { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", "Quickfix List (Trouble)" },
}) do
  vim.keymap.set("n", m[1], m[2], { desc = m[3] })
end

-- treesitter ----------------------------------------------------------------
require("nvim-treesitter").setup()
if #vim.api.nvim_get_runtime_file("parser/lua.so", false) == 0 then
  -- Non-image safety net only; in the baked image parsers exist so this never fires.
  require("nvim-treesitter").install(require("config.parsers"))
end
vim.api.nvim_create_autocmd("FileType", {
  callback = function(ev)
    pcall(vim.treesitter.start, ev.buf)
  end,
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "turtle", "sparql", "graphql", "scss" },
  callback = function(ev)
    vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})
