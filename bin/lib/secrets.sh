# shellcheck shell=bash
# v3 module: Doppler project secrets — ONE download, injected as env.
# Contract: v3_secrets -> appends -e flags to OPTS. No-op if doppler is absent or
# the project has no Doppler config. (Phase 0 finding: v2 downloaded twice.)
# Note: -e injection is visible in `docker inspect`; that is the existing v2
# contract. A future hardening could switch to an env-file mount.

v3_secrets() {
  command -v doppler >/dev/null 2>&1 || return 0
  local env_out; env_out="$(doppler secrets download --format env --no-file 2>/dev/null || true)"
  [ -n "$env_out" ] || return 0
  local line
  while IFS= read -r line; do
    [ -n "$line" ] && OPTS+=(-e "$line")
  done <<< "$env_out"
}
