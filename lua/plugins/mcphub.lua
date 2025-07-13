return {
  {
    "ravitemer/mcphub.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    },
    opts = {
      extensions = {
        avante = {
          make_slash_commands = true, -- make /slash commands from MCP server prompts
        }
      }
    },
    cmd = { "McpHub" },
    keys = {
      { "<leader>mh", "<cmd>McpHub<cr>", desc = "Open MCP Hub" },
    },
  },
}