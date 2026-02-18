local M = {}

M.find_package_json = function()
  local buf_dir = vim.fn.expand('%:p:h')
  local find_package_json = function(path)
    local result = vim.fn.findfile('package.json', path .. ';')
    if result ~= '' then
      return vim.fn.fnamemodify(result, ':h')
    end
  end
  return find_package_json(buf_dir)
end


return {
  {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    config = true,
  },
  {
    "terrortylor/nvim-comment",
    lazy = false,
    keys = {
      { "<Leader>/", "<CMD>CommentToggle<CR>", mode = { "n" } },
      { "<Leader>/", ":'<,'>CommentToggle<CR>gv<esc>", mode = { "v" } },
    },
    main = "nvim_comment",
    config = true,
  },
  {
    'stevearc/conform.nvim',
    opts = {
      formatters_by_ft = {
        html = { 'prettierd', stop_after_first = true },
        lua = { 'stylua' },
        javascript = { 'eslint', 'biome' },
        javascriptreact = { 'eslint', 'biome' },
        markdown = { 'prettierd', stop_after_first = true },
        typescript = { 'eslint', 'biome' },
        typescriptreact = { 'eslint', 'biome' },
        ['*'] = { 'trim_whitespace' },
        python = { 'black', 'isort' },
        scss = { 'stylelint' },
        css = { 'stylelint', 'biome' },
        json = { 'biome' },
      },
      log_level = vim.log.levels.DEBUG,
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      },
      formatters = {
        prettierd = {
          condition = function()
            return (vim.uv or vim.loop).fs_realpath('.prettierrc.js') ~= nil
              or (vim.uv or vim.loop).fs_realpath('.prettierrc.mjs') ~= nil
          end,
        },
        stylelint = {
          cwd = M.find_package_json,
        },
      },
    },
    keys = {
      {
        "<leader>f",
        function()
          require("conform").format({ async = true })
        end,
        desc = "Format the current buffer",
      },
    },
  },
}
