-- Configure LSP servers via vim.lsp.config (Neovim 0.11+ native API)

-- Advertise blink.cmp's completion capabilities to every server ('*' is the
-- lowest-priority default; per-server configs merge on top). pcall keeps the
-- headless Docker build pass working even if blink isn't loadable yet.
local ok, blink = pcall(require, "blink.cmp")
if ok then
  vim.lsp.config("*", { capabilities = blink.get_lsp_capabilities() })
end

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

-- Make diagnostics visible. Neovim 0.11+ defaults virtual_text OFF, so without
-- this the editor shows almost nothing. jump.float=true is REQUIRED before the
-- deprecated [d/]d float remaps are removed (keymaps.lua).
vim.diagnostic.config({
  virtual_text = { current_line = true, source = "if_many" },
  severity_sort = true,
  float = { border = "rounded", source = true },
  jump = { float = true },
})

return {
  {
    "neovim/nvim-lspconfig",
    event = "BufReadPre",
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
}
