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
# Usage: v3 [--host-tool NAME]... [nvim args...] [file...]
#   --host-tool NAME      bind-mount an extra host-global binary (repeatable)
#   V3_HOST_TOOLS="a b"   same, via env
#   NVIM_IMAGE=...        override the image (default fwrlines/nvim3:local)
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

# Image: local tag for now. TODO(GHCR): read from core/versions.env after push.
DOCKER_IMAGE="${NVIM_IMAGE:-fwrlines/nvim3:local}"
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
ARGS=()
while [ $# -gt 0 ]; do
  case "$1" in
    --host-tool)
      [ $# -ge 2 ] || { echo "v3: --host-tool needs a tool name" >&2; exit 2; }
      V3_HOST_TOOL_LIST+=("$2"); shift 2 ;;
    --host-tool=*) V3_HOST_TOOL_LIST+=("${1#*=}"); shift ;;
    --) shift; while [ $# -gt 0 ]; do ARGS+=("$1"); shift; done ;;
    *) ARGS+=("$1"); shift ;;
  esac
done

# --- compose the docker-run flags via the modules ---
OPTS=(--rm -it -v "$(pwd):/x/")
v3_venv
v3_host_tools
v3_copilot
v3_term
v3_secrets
v3_gitident

exec "$DOCKER" run "${OPTS[@]}" "$DOCKER_IMAGE" "${ARGS[@]}"
