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
    "terrortylor/nvim-comment",
    lazy = false,
    keys = {
      { "<Leader>/", "<CMD>CommentToggle<CR>", mode = { "n" }, desc = "Toggle comment" },
      { "<Leader>/", ":'<,'>CommentToggle<CR>gv<esc>", mode = { "v" }, desc = "Toggle comment (visual)" },
    },
    main = "nvim_comment",
    config = true,
  },
  {
    "stevearc/conform.nvim",
    -- Arm format-on-save: without a load trigger, conform is keys-only lazy and
    -- its BufWritePre autocmd never registers in a fresh --rm container.
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    opts = {
      -- NOTE (Phase 2): the JS/TS/CSS formatter set still references binaries
      -- not yet in the image (biome, prettierd, black, isort, stylelint) and
      -- gets consolidated onto biome + ruff in Phase 2. Phase 0 only removes the
      -- invalid "eslint" formatter name (no such conform builtin).
      formatters_by_ft = {
        html = { "prettierd", stop_after_first = true },
        lua = { "stylua" },
        javascript = { "biome" },
        javascriptreact = { "biome" },
        markdown = { "prettierd", stop_after_first = true },
        typescript = { "biome" },
        typescriptreact = { "biome" },
        ["*"] = { "trim_whitespace" },
        python = { "black", "isort" },
        scss = { "stylelint" },
        css = { "stylelint", "biome" },
        json = { "biome" },
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
      formatters = {
        prettierd = {
          condition = function()
            return (vim.uv or vim.loop).fs_realpath(".prettierrc.js") ~= nil
              or (vim.uv or vim.loop).fs_realpath(".prettierrc.mjs") ~= nil
          end,
        },
        stylelint = {
          cwd = M.find_package_json,
        },
      },
    },
    config = function(_, opts)
      require("conform").setup(opts)

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
