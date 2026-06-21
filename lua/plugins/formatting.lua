local M = {}

M.find_package_json = function()
  local buf_dir = vim.fn.expand("%:p:h")
  local find_package_json = function(path)
    local result = vim.fn.findfile("package.json", path .. ";")
    if result ~= "" then
      return vim.fn.fnamemodify(result, ":h")
    end
  end
  return find_package_json(buf_dir)
end

-- Track format-on-save state
local format_on_save = true
local format_disabled_bufs = {}

return {
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true,
  },
  {
    "stevearc/conform.nvim",
    -- Arm format-on-save: without a load trigger, conform is keys-only lazy and
    -- its BufWritePre autocmd never registers in a fresh --rm container.
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    opts = {
      -- Tool SOURCE model (glibc image):
      --   PROJECT tools resolve from the mounted working env on PATH (project
      --   node_modules/.bin + venv) so the version MATCHES the project — never
      --   baked, no version mismatch. If a project lacks the tool, conform
      --   silently skips that filetype (graceful). These: biome (js/ts/json/css),
      --   ruff (python), prettier (markdown/html).
      --   EDITOR tools are baked (not project-versioned): stylua (lua), shfmt (sh).
      -- glibc base => host-built project binaries run natively in the container.
      formatters_by_ft = {
        lua = { "stylua" }, -- baked
        sh = { "shfmt" }, -- baked
        python = { "ruff_organize_imports", "ruff_format" }, -- project venv
        javascript = { "biome" }, -- project node_modules
        javascriptreact = { "biome" },
        typescript = { "biome" },
        typescriptreact = { "biome" },
        json = { "biome" },
        jsonc = { "biome" },
        css = { "biome" },
        scss = { "biome" },
        markdown = { "prettier" }, -- project node_modules (none -> skipped)
        html = { "prettier" },
        ["_"] = { "trim_whitespace" }, -- fallback for any unlisted filetype
      },
      -- Resolve PROJECT formatters by walking UP from the file to the nearest
      -- node_modules/.bin (monorepo per-package/hoisted layouts: bun isolated
      -- installs scatter biome across configs/*/ and packages/*/, never root).
      -- Baked tools (stylua/shfmt) ignore this and use the image PATH.
      formatters = {
        biome = { prefer_local = "node_modules/.bin" },
        prettier = { prefer_local = "node_modules/.bin" },
      },
      format_on_save = function(bufnr)
        if not format_on_save or format_disabled_bufs[bufnr] then
          return
        end
        return {
          timeout_ms = 1000,
          lsp_format = "fallback",
        }
      end,
    },
    config = function(_, opts)
      require("conform").setup(opts)
      -- No not-found notice: under mount-cwd it is NORMAL for project tools to be
      -- absent. Status is queried on demand via :ToolStatus (lua/config/tools.lua).

      -- :FormatToggle - toggle format-on-save globally
      vim.api.nvim_create_user_command("FormatToggle", function()
        format_on_save = not format_on_save
        vim.notify("Format on save: " .. (format_on_save and "ON" or "OFF"))
      end, { desc = "Toggle format-on-save globally" })

      -- :FormatToggleBuf - toggle format-on-save for current buffer
      vim.api.nvim_create_user_command("FormatToggleBuf", function()
        local bufnr = vim.api.nvim_get_current_buf()
        format_disabled_bufs[bufnr] = not format_disabled_bufs[bufnr]
        vim.notify("Format on save (buffer): " .. (format_disabled_bufs[bufnr] and "OFF" or "ON"))
      end, { desc = "Toggle format-on-save for current buffer" })
    end,
    keys = {
      {
        "<leader>f",
        function()
          require("conform").format({ async = true })
        end,
        desc = "Format buffer",
      },
      {
        "<leader>F",
        "<cmd>FormatToggle<cr>",
        desc = "Toggle format-on-save",
      },
    },
  },
}
