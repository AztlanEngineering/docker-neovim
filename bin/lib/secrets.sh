# shellcheck shell=bash
# v3 module: Doppler project secrets — ONE download, injected as env.
# Contract: v3_secrets -> appends -e flags to OPTS. No-op if doppler is absent or
# the project has no Doppler config. (Phase 0 finding: v2 downloaded twice.)
#
# --format docker (NOT env): emits bare KEY=value, which is what `docker -e` wants.
# --format env wraps values in double-quotes (KEY="value") for shell sourcing;
# docker -e does NOT strip them, so env-format corrupts every secret with literal
# surrounding quotes inside the container. (2nd-pass swarm finding.)
#
# Note: -e injection is visible in `docker inspect` — the existing v2 contract.
# A future hardening (deferred to the AI phase) could switch to an --env-file mount.

v3_secrets() {
  # OPT-IN, default OFF ([v2-secrets] flip 2026-07-12): the AI-light editor
  # consumes no project secrets by default — injecting the whole Doppler config
  # on every launch was exactly CR-6's over-injection (and shows in `docker
  # inspect`). Enable per run: `v3 --secrets` or V3_SECRETS=1.
  [ "${V3_SECRETS:-0}" = "1" ] || return 0
  command -v doppler >/dev/null 2>&1 || return 0
  local env_out; env_out="$(doppler secrets download --format docker --no-file 2>/dev/null || true)"
  [ -n "$env_out" ] || return 0
  local line
  while IFS= read -r line; do
    [ -n "$line" ] && OPTS+=(-e "$line")
  done <<< "$env_out"
}
