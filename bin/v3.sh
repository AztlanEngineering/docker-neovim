#!/usr/bin/env bash
# v3 — launch the refreshed (Phase 0–2) glibc editor image.
#
# Thin orchestrator: each launch heuristic is a module in bin/lib/*.sh that
# appends docker-run flags to the OPTS array. See docs/LAUNCHER.md and
# df/session/NVIM/TOOL-RESOLUTION-STORIES.md.
#
# Contract summary:
#   * mounts $(pwd) at /x  (mount = cwd; launch from the repo root for a
#     monorepo's full toolchain — tools above the mount are not visible)
#   * venv automount (lib/venv.sh), host-global tools per-tool (lib/hosttools.sh),
#     Doppler once (lib/secrets.sh), Copilot ro (lib/copilot.sh), git identity
#     (lib/gitident.sh), TERM/COLORTERM (lib/term.sh)
#   * NO ANTHROPIC key (Phase 0 stripped AI to a toggleable Copilot)
#
# Usage: v3 [--host-tool NAME]... [--tidal] [nvim args...] [file...]
#   --host-tool NAME      bind-mount an extra host-global binary (repeatable)
#   --tidal               mount the host tmux socket for the TidalCycles rig
#                         (lib/tidal.sh; V3_TIDAL=1 via env) — [tidal-rig] L3
#   V3_HOST_TOOLS="a b"   same, via env
#   NVIM_IMAGE=...        override the image (default nvim:local)
#   V3_DOCKER=podman      use a different OCI runtime
set -euo pipefail

# Resolve this script's dir so lib/ is found regardless of how v3 is invoked.
_V3_SELF="$(readlink -f "${BASH_SOURCE[0]}")"
_V3_DIR="$(dirname "$_V3_SELF")"
# shellcheck source=lib/venv.sh
. "$_V3_DIR/lib/venv.sh"
# shellcheck source=lib/hosttools.sh
. "$_V3_DIR/lib/hosttools.sh"
# shellcheck source=lib/secrets.sh
. "$_V3_DIR/lib/secrets.sh"
# shellcheck source=lib/copilot.sh
. "$_V3_DIR/lib/copilot.sh"
# shellcheck source=lib/gitident.sh
. "$_V3_DIR/lib/gitident.sh"
# shellcheck source=lib/term.sh
. "$_V3_DIR/lib/term.sh"
# shellcheck source=lib/tidal.sh
. "$_V3_DIR/lib/tidal.sh"

# Image resolution, in precedence: explicit $NVIM_IMAGE env > versions.env (the
# fleet pointer written by bin/push.sh; digest-pinned) > local build tag.
if [ -z "${NVIM_IMAGE:-}" ] && [ -f "$_V3_DIR/../versions.env" ]; then
  # shellcheck disable=SC1090
  . "$_V3_DIR/../versions.env"
fi
DOCKER_IMAGE="${NVIM_IMAGE:-nvim:local}"
DOCKER="${V3_DOCKER:-docker}"

# --- host-tool list: default set + V3_HOST_TOOLS env + --host-tool flags ---
# Project-versioned lang tools come from the host (TOOL POLICY, PLAN-DECISIONS #12):
# sem-lsp (RDF) + rust-analyzer (mounted from host ~/.cargo/bin when present).
# Absent tools simply don't mount (graceful).
V3_HOST_TOOL_LIST=(sem-lsp rust-analyzer)
if [ -n "${V3_HOST_TOOLS:-}" ]; then
  # shellcheck disable=SC2206
  V3_HOST_TOOL_LIST+=(${V3_HOST_TOOLS})
fi
CHECK=0
ARGS=()
while [ $# -gt 0 ]; do
  case "$1" in
    --check) CHECK=1; shift ;;
    --secrets) V3_SECRETS=1; shift ;;
    --tidal) V3_TIDAL=1; shift ;;
    --host-tool)
      [ $# -ge 2 ] || { echo "v3: --host-tool needs a tool name" >&2; exit 2; }
      V3_HOST_TOOL_LIST+=("$2"); shift 2 ;;
    --host-tool=*) V3_HOST_TOOL_LIST+=("${1#*=}"); shift ;;
    --) shift; while [ $# -gt 0 ]; do ARGS+=("$1"); shift; done ;;
    *) ARGS+=("$1"); shift ;;
  esac
done

# --- narrow-mount guard -----------------------------------------------------
# mount = cwd (decision #8): anything ABOVE $(pwd) does not exist in the
# container. Launching below a repo root amputates the project's toolchain AND
# its configs (biome.json etc.) — formatters would be silently absent (or, with
# host fallbacks, silently wrong). Warn, don't block: narrow launches are
# legitimate when intended.
_git_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [ -n "$_git_root" ] && [ "$_git_root" != "$(pwd -P)" ]; then
  printf 'v3: WARN cwd is below the repo root (%s) — the toolchain above the mount is invisible; launch from the root for the full project env\n' "$_git_root" >&2
fi
unset _git_root

# --- compose the docker-run flags via the modules ---
if [ "$CHECK" -eq 1 ]; then
  # headless probe: no TTY/stdin, and no secrets — a toolchain report must not
  # pull the vault
  OPTS=(--rm -v "$(pwd):/x/")
else
  OPTS=(--rm -it -v "$(pwd):/x/")
fi
# uid mapping — BACK-PORTED from df's vendored copy 2026-08-01 (it landed
# fleet-side first, for u1). The image bakes `USER 1000:1000`; under ROOTLESS
# PODMAN the default mapping sends your host uid to container-root, so mounted
# files land root-owned inside and the uid-1000 editor can't write them.
# `keep-id:uid=1000,gid=1000` remaps YOUR host uid — whatever it is — to 1000
# inside: host-uid-agnostic, correct on every machine. Podman ONLY (docker
# would error on the flag), detected TWO ways because the NixOS dockerCompat
# shim prints "docker version ..." and only the resolved binary path betrays
# podman.
if "$DOCKER" --version 2>/dev/null | grep -qi podman \
   || readlink -f "$(command -v "$DOCKER" 2>/dev/null)" 2>/dev/null | grep -qi podman; then
  OPTS+=(--userns=keep-id:uid=1000,gid=1000)
fi
v3_venv
v3_host_tools
v3_copilot
v3_term
v3_tidal
[ "$CHECK" -eq 1 ] || v3_secrets
v3_gitident

if [ "$CHECK" -eq 1 ]; then
  # `v3 --check [files...]` — mount the probe (lives in this repo, NOT baked:
  # it iterates on the launcher's cadence) and print the cwd's toolchain report:
  # every LSP + formatter with its TYPED origin (project/venv/host/baked, per
  # the declared V3_ORIGIN_HOST_TOOLS metadata). See lib/check.lua.
  OPTS+=(-v "$_V3_DIR/lib/check.lua:/df-check.lua:ro" -e "NVIM_IMAGE=$DOCKER_IMAGE")
fi

# No exec: the EXIT trap must run to remove the per-session copilot copy.
_v3_cleanup() { [ -n "${_V3_COPILOT_TMP:-}" ] && rm -rf "$_V3_COPILOT_TMP"; }
trap _v3_cleanup EXIT

if [ "$CHECK" -eq 1 ]; then
  "$DOCKER" run "${OPTS[@]}" "$DOCKER_IMAGE" --headless "+luafile /df-check.lua" "${ARGS[@]}"
else
  "$DOCKER" run "${OPTS[@]}" "$DOCKER_IMAGE" "${ARGS[@]}"
fi
