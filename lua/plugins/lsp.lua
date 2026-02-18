-- Configure LSP servers via vim.lsp.config (Neovim 0.11+ native API)
vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      telemetry = { enable = false },
    },
  },
})

-- Enable system-installed LSP servers (not managed by Mason)
-- lua-language-server and rust-analyzer are installed via apk on Alpine
vim.lsp.enable({ "lua_ls", "rust_analyzer" })

return {
  {
    "neovim/nvim-lspconfig",
    event = "BufReadPre",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      -- Default keymaps for all LSP buffers
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local function bmap(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = args.buf, desc = desc })
          end

          bmap("n", "gd", vim.lsp.buf.definition, "Go to definition")
          bmap("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
          bmap("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
          bmap("n", "gr", vim.lsp.buf.references, "Find references")
          bmap("n", "K", vim.lsp.buf.hover, "Hover documentation")
          bmap("n", "<C-k>", vim.lsp.buf.signature_help, "Signature help")
          bmap("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
          bmap("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
        end,
      })
    end,
  },
  {
    "zbirenbaum/copilot.lua",
    event = "InsertEnter",
    config = true,
    opts = {
      suggestion = {
        enabled = true,
        auto_trigger = true,
      },
    },
  },
  {
    "zbirenbaum/copilot-cmp",
    event = "InsertEnter",
    config = true,
  },
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      {
        "L3MON4D3/LuaSnip",
        version = "v2.*",
        build = "make install_jsregexp",
      },
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-emoji",
      "hrsh7th/cmp-cmdline",
      "onsails/lspkind.nvim",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      require("luasnip.loaders.from_vscode").lazy_load()

      local has_words_before = function()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0
          and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-d>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.close(),
          ["<CR>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              if luasnip.expandable() then
                luasnip.expand()
              else
                cmp.confirm({ select = true })
              end
            else
              fallback()
            end
          end),
          -- Unified Tab: cmp menu > copilot ghost text > luasnip jump > complete > fallback
          ["<Tab>"] = cmp.mapping(function(fallback)
            local copilot_ok, copilot = pcall(require, "copilot.suggestion")
            if cmp.visible() then
              cmp.select_next_item()
            elseif copilot_ok and copilot.is_visible() then
              copilot.accept()
            elseif luasnip.locally_jumpable(1) then
              luasnip.jump(1)
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp", group_index = 1 },
          { name = "copilot", group_index = 2 },
          { name = "luasnip", group_index = 3 },
          { name = "buffer", group_index = 4 },
          { name = "path" },
          { name = "emoji", group_index = 9 },
        }),
      })

      vim.o.completeopt = "menuone,noinsert,noselect"
      vim.cmd([[highlight! default link CmpItemKind CmpItemMenuDefault]])
    end,
  },
}
