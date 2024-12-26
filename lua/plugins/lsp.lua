local function copilot_tab_complete()
  if require("copilot.suggestion").is_visible() then
    require("copilot.suggestion").accept()
  else
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, false, true), "n", false)
  end
end

return {
  {
    "VonHeikemen/lsp-zero.nvim",
    event = "BufReadPre",
    branch = "v3.x",
    dependencies = {
      "neovim/nvim-lspconfig",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/nvim-cmp",
      "L3MON4D3/LuaSnip",
    },
    config = function()
      local lsp_zero = require("lsp-zero")

      -- lsp.preset("recommended")
      lsp_zero.on_attach(function(client, bufnr)
        lsp_zero.default_keymaps({ buffer = bufnr })
      end)
      lsp_zero.setup()
      require("lspconfig").ts_ls.setup({})

      require("lspconfig").stylelint_lsp.setup({})

      require("lspconfig").lua_ls.setup({
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" },
            },
          },
        },
        on_init = function(client)
          local uv = vim.uv or vim.loop
          local path = client.workspace_folders[1].name

          -- Don't do anything if there is a project local config
          if uv.fs_stat(path .. "/.luarc.json") or uv.fs_stat(path .. "/.luarc.jsonc") then
            return
          end

          -- Apply neovim specific settings
          local lua_opts = lsp_zero.nvim_lua_ls()

          client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, lua_opts.settings.Lua)
        end,
      })

      require("mason").setup({})
      require("mason-lspconfig").setup({
        handlers = {
          function(server_name)
            require("lspconfig")[server_name].setup({})
          end,
        },
      })
      -- vim.diagnostic.config { virtual_text = true }
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
    keys = {
      {
        "<Tab>",
        function()
          copilot_tab_complete()
        end,
        mode = { "i" },
        silent = true,
        noremap = true,
      },
    },
  },
  {
    "zbirenbaum/copilot-cmp",
    event = "InsertEnter",
    config = true,
  },
  {
    -- opts = function(_, opts)
    --   table.insert(opts.sources, { name = "emoji" })
    -- end,
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-buffer", -- source for text in buffer
      "hrsh7th/cmp-path", -- source for file system paths
      {
        "L3MON4D3/LuaSnip",
        -- follow latest release.
        version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
        -- install jsregexp (optional!).
        build = "make install_jsregexp",
      },
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-emoji",
      "hrsh7th/cmp-cmdline",
      "onsails/lspkind.nvim", -- vs-code like pictograms
    },
    config = function()
      local cmp = require("cmp")
      local lspkind = require("lspkind")
      local luasnip = require("luasnip")

      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        -- formatting = {
        --   format = lspkind.cmp_format({
        --     mode = 'symbol', -- show only symbol annotations
        --     maxwidth = 50, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
        --                    -- can also be a function to dynamically calculate max width such as
        --                    -- maxwidth = function() return math.floor(0.45 * vim.o.columns) end,
        --     ellipsis_char = '...', -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
        --     show_labelDetails = true, -- show labelDetails in menu. Disabled by default

        --     -- The function below will be called before any actual modifications from lspkind
        --     -- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
        --     before = function (entry, vim_item)
        --       return vim_item
        --     end
        --   })
        -- },
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          -- ['<Tab>'] = cmp.mapping(function(fallback)
          --   if cmp.visible() then
          --     cmp.select_next_item()
          --   elseif luasnip.expand_or_jumpable() then
          --     luasnip.expand_or_jump()
          --   elseif require("copilot.suggestion").is_visible() then
          --     require("copilot.suggestion").accept()
          --   else
          --     fallback()
          --   end
          -- end, { "i", "s" }),
          -- ['<S-Tab>'] = cmp.mapping(function(fallback)
          --   if cmp.visible() then
          --     cmp.select_prev_item()
          --   elseif luasnip.jumpable(-1) then
          --     luasnip.jump(-1)
          --   else
          --     fallback()
          --   end
          -- end, { "i", "s" }),
          ["<C-d>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.close(),
          ["<CR>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              if luasnip.expandable() then
                luasnip.expand()
              else
                cmp.confirm({
                  select = true,
                })
              end
            else
              fallback()
            end
          end),
        }),
        sources = cmp.config.sources({
          -- Copilot Source
          { name = "copilot", group_index = 1 },
          { name = "nvim_lsp", group_index = 2 },
          { name = "luasnip", group_index = 3 },
          { name = "buffer", group_index = 4 },
          { name = "path" },
          { name = "emoji", group_index = 9 },
          -- { name = "cmdline" },
        }),
      })

      vim.cmd([[
      set completeopt=menuone,noinsert,noselect
      highlight! default link CmpItemKind CmpItemMenuDefault
    ]])
    end,
  },
}
