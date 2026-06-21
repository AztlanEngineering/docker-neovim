# shellcheck shell=bash
# v3 module: GitHub Copilot config, mounted READ-ONLY (Copilot needs only to read
# its credentials; rw would let the container rewrite host OAuth tokens).
# Contract: v3_copilot -> appends a -v flag to OPTS if the config dir exists.
# Harmless when Copilot is toggled off in the image (lua/config/ai.lua).

v3_copilot() {
  local dir="${XDG_CONFIG_HOME:-$HOME/.config}/github-copilot"
  [ -d "$dir" ] && OPTS+=(-v "$dir:/home/myuser/.config/github-copilot:ro")
  return 0
}
