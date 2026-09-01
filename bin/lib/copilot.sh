# shellcheck shell=bash
# v3 module: GitHub Copilot credentials — a per-session THROWAWAY COPY, mounted
# rw ([copilot-cred-mount], 2026-07-12). Why not :ro — Copilot writes
# versions.json beside its creds and degrades silently read-only. Why not the
# live dir rw — the container could rewrite the HOST's OAuth tokens (the audited
# v2 defect). So: copy to a private tmpdir per launch, mount THAT rw; container
# writes land in the throwaway; v3.sh removes it on exit (_V3_COPILOT_TMP).

v3_copilot() {
  local dir="${XDG_CONFIG_HOME:-$HOME/.config}/github-copilot"
  [ -d "$dir" ] || return 0
  _V3_COPILOT_TMP="$(mktemp -d "${TMPDIR:-/tmp}/v3-copilot.XXXXXX")"
  cp -a "$dir/." "$_V3_COPILOT_TMP/" 2>/dev/null || true
  OPTS+=(-v "$_V3_COPILOT_TMP:/home/myuser/.config/github-copilot")
  return 0
}
