return {
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    lazy = false,
    version = false,
    build = "make BUILD_FROM_SOURCE=true",
    -- build = function()
    -- -- conditionally use the correct build system for the current OS
    --   if vim.fn.has("win32") == 1 then
    --     return "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
    --   else
    --     return "make"
    --   end
    -- end,
    opts = {
      provider = "claude", -- Main provider for chat/code generation
      auto_suggestions_provider = "copilot", -- Free auto-suggestions
      providers = {
        claude = {
          endpoint = "https://api.anthropic.com",
          model = "claude-sonnet-4-20250514", -- Claude 4 Sonnet as default (latest)
          api_key_name = "ANTHROPIC_API_KEY",
          extra_request_body = {
            temperature = 0,
            max_tokens = 4096,
          },
        },
        opus4 = {
          __inherited_from = "claude",
          model = "claude-opus-4-20250514", -- Claude 4 Opus (latest)
          extra_request_body = {
            temperature = 0,
            max_tokens = 4096,
          },
        },
        gemini = {
          endpoint = "https://generativelanguage.googleapis.com/v1beta/models",
          model = "gemini-2.5-flash", -- Gemini 2.5 Flash
          api_key_name = "GEMINI_API_KEY",
          extra_request_body = {
            temperature = 0,
            max_tokens = 4096,
          },
        },
      },
      -- MCP Hub integration
      system_prompt = function()
        local ok, mcphub = pcall(require, "mcphub")
        if ok then
          local hub = mcphub.get_hub_instance()
          return hub and hub:get_active_servers_prompt() or ""
        end
        return ""
      end,
      custom_tools = function()
        local ok, mcphub_avante = pcall(require, "mcphub.extensions.avante")
        if ok then
          return {
            mcphub_avante.mcp_tool(),
          }
        end
        return {}
      end,
    },
    build = "make",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim", 
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
      "zbirenbaum/copilot.lua",
      {
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
          },
        },
      },
      {
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
    keys = {
      -- Default Avante keybindings
      { "<leader>aa", "<cmd>AvanteAsk<cr>", desc = "Avante: Ask" },
      { "<leader>ae", "<cmd>AvanteEdit<cr>", desc = "Avante: Edit" },
      { "<leader>ar", "<cmd>AvanteRefresh<cr>", desc = "Avante: Refresh" },
      { "<leader>af", "<cmd>AvanteFocus<cr>", desc = "Avante: Focus" },
      { "<leader>at", "<cmd>AvanteToggle<cr>", desc = "Avante: Toggle" },
      { "<leader>ac", "<cmd>AvanteClear<cr>", desc = "Avante: Clear" },
      { "<leader>ap", "<cmd>AvantePaste<cr>", desc = "Avante: Paste" },
      -- Model switching keybindings
      { "<leader>as", "<cmd>AvanteProvider claude<cr>", desc = "Avante: Use Claude 4 Sonnet (default)" },
      { "<leader>ao", "<cmd>AvanteProvider opus4<cr>", desc = "Avante: Use Claude 4 Opus" },
      { "<leader>ag", "<cmd>AvanteProvider gemini<cr>", desc = "Avante: Use Gemini 2.5 Flash" },
      -- Visual mode bindings
      { "<leader>aa", "<cmd>AvanteAsk<cr>", mode = "v", desc = "Avante: Ask (visual)" },
      { "<leader>ae", "<cmd>AvanteEdit<cr>", mode = "v", desc = "Avante: Edit (visual)" },
    },
  },
}
