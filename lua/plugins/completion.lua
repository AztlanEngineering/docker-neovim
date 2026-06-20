-- Completion — blink.cmp, replacing the 12-spec nvim-cmp stack.
--
-- Design (Phase 0):
--  * pinned to the v1 line (version = "1.*"); v2 carries breaking changes.
--  * fuzzy.implementation = "lua": NO native binary. The Rust matcher would
--    be downloaded at runtime, which evaporates every --rm launch and breaks
--    the digest-pinned image contract. Lua is deterministic and fast enough.
--  * loaded eagerly (lazy = false): the LSP capabilities blink advertises must
--    be available before the first server attaches.
--  * sources: lsp + path + snippets (native vim.snippet) + buffer, plus
--    copilot ONLY when enabled in lua/config/ai.lua.
--  * Cozette bitmap font: text kind column, no nerd-glyph icons (tofu risk).

local ai = require("config.ai")

local default_sources = { "lsp", "path", "snippets", "buffer" }
local providers = {}

if ai.enable_copilot then
  table.insert(default_sources, "copilot")
  providers.copilot = {
    name = "copilot",
    module = "blink-cmp-copilot",
    score_offset = 100, -- surface Copilot above buffer words
    async = true,
  }
end

local dependencies = {}
if ai.enable_copilot then
  table.insert(dependencies, "giuxtaposition/blink-cmp-copilot")
end

return {
  {
    "saghen/blink.cmp",
    version = "1.*",
    lazy = false,
    dependencies = dependencies,
    opts = {
      keymap = { preset = "enter" }, -- <CR> confirms only an explicit selection
      appearance = {
        nerd_font_variant = "normal",
        kind_icons = nil, -- text kind labels, no glyphs (Cozette-safe)
      },
      completion = {
        menu = {
          draw = { columns = { { "label", "label_description", gap = 1 }, { "kind" } } },
        },
        documentation = { auto_show = true },
        ghost_text = { enabled = false },
      },
      sources = {
        default = default_sources,
        providers = providers,
      },
      snippets = { preset = "default" }, -- native vim.snippet
      fuzzy = { implementation = "lua" },
      signature = { enabled = true },
    },
  },
}
