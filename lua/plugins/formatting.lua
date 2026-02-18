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
    opts = {
      formatters_by_ft = {
        html = { "prettierd", stop_after_first = true },
        lua = { "stylua" },
        javascript = { "eslint", "biome" },
        javascriptreact = { "eslint", "biome" },
        markdown = { "prettierd", stop_after_first = true },
        typescript = { "eslint", "biome" },
        typescriptreact = { "eslint", "biome" },
        ["*"] = { "trim_whitespace" },
        python = { "black", "isort" },
        scss = { "stylelint" },
        css = { "stylelint", "biome" },
        json = { "biome" },
      },
      log_level = vim.log.levels.DEBUG,
      format_on_save = function(bufnr)
        if not format_on_save or format_disabled_bufs[bufnr] then
          return
        end
        return {
          timeout_ms = 500,
          lsp_fallback = true,
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
