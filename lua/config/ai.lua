-- AI feature toggles — the single switch for in-editor AI.
--
-- Phase 0 policy: the ONLY AI surface is Copilot, as a completion source.
-- Set enable_copilot = false to drop it entirely: no ghost text, no Copilot
-- completion source, copilot.lua never loads, nothing tries to authenticate.
--
-- (Avante, Claude Code and MCP were removed in Phase 0; richer AI is a
-- deliberate follow-up — see df/session/NVIM/.)

return {
  enable_copilot = true,
}
