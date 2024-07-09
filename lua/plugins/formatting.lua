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
    config = true
    -- use opts = {} for passing setup options
    -- this is equalent to setup({}) function
  },
  { "terrortylor/nvim-comment",
    lazy = false,
    keys = {
        { "<Leader>/", "<CMD>CommentToggle<CR>", mode = { "n" } },
        -- { "<C-_>", "<C-\\><C-N><CMD>CommentToggle<CR>ji", mode = { "i" } },
        { "<Leader>/", ":'<,'>CommentToggle<CR>gv<esc>", mode = { "v" } },
    },
    main="nvim_comment",
    config = true
  },
  {
    'stevearc/conform.nvim',
    opts = {
      formatters_by_ft = {
        html = { { 'prettierd' } },
        lua = { 'stylua' },
        javascript = { 'eslint' },
        javascriptreact = { 'eslint' },
        markdown = { { 'prettierd' } },
        typescript = { 'eslint' },
        typescriptreact = { 'eslint' },
        ['*'] = { 'trim_whitespace' },
        python = { 'black', 'isort'},
        scss = { 'stylelint' },
        css = { 'stylelint' },
      },
      log_level = vim.log.levels.DEBUG,
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      },
      formatters = {
        prettierd = {
          condition = function()
            return vim.loop.fs_realpath('.prettierrc.js') ~= nil or vim.loop.fs_realpath('.prettierrc.mjs') ~= nil
          end,
        },
        stylelint = {
          cwd = M.find_package_json,
        }
      },
    },
    keys = {
      {
        "<leader>f",
        function()
          require("conform").format({ async = true })
        end,
        desc = "Format the current buffer"
      }
    }
  },
}
