-- Copilot — kept as a single, toggleable completion source.
--
-- Wired the modern way: copilot.lua provides ONLY the auth + LSP backend;
-- its inline ghost-text (suggestion) and panel are disabled, because the
-- completion menu surfaces Copilot via blink-cmp-copilot instead (see
-- completion.lua). This avoids the old double-integration (ghost text AND
-- a cmp source racing on every keystroke).
--
-- Toggle in lua/config/ai.lua: enable_copilot = false removes this entirely.

local ai = require("config.ai")

if not ai.enable_copilot then
  return {}
end

return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      suggestion = { enabled = false }, -- menu source only, no ghost text
      panel = { enabled = false },
    },
  },
}
