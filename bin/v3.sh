#!/usr/bin/env bash
# v3 — launch the refreshed (Phase 0–2) glibc editor image.
#
# Parallel to v2 during the transition. Contract (see docs/LAUNCHER.md):
#   * mounts $(pwd) at /x (mount = cwd; launch from the repo root for the full
#     monorepo toolchain — tools above the mount are not visible)
#   * auto-mounts a Python venv (+ VIRTUAL_ENV/PYTHONPATH) so project ruff/python
#     resolve from the venv (glibc image -> host venv binaries run natively)
#   * mounts the GitHub Copilot config read-only (if Copilot is enabled)
#   * forwards TERM/COLORTERM (truecolor + undercurl from foot)
#   * injects Doppler project secrets ONCE (env), and a git identity for
#     in-container checkpoint commits
#   * bind-mounts host-global tools per-tool: sem-lsp by default, plus any named
#     by --host-tool NAME (repeatable) or V3_HOST_TOOLS="a b c"
#   * NO ANTHROPIC key (Phase 0 stripped AI to a toggleable Copilot)
#
# Usage: v3 [--host-tool NAME]... [nvim args...] [file...]
set -euo pipefail

# Image: local tag for now. TODO(GHCR): switch to a digest read from
# core/versions.env once the base is pushed (see docs/LAUNCHER.md).
DOCKER_IMAGE="${NVIM_IMAGE:-fwrlines/nvim3:local}"
DOCKER="${V3_DOCKER:-docker}"   # set V3_DOCKER=podman on rootless-podman hosts

OPTS=(--rm -it -v "$(pwd):/x/")

# ---- host-global tools (per-tool opt-in; sem-lsp is the default) ----
HOST_TOOLS=(sem-lsp)
# extra tools from the env list...
if [ -n "${V3_HOST_TOOLS:-}" ]; then
  # shellcheck disable=SC2206
  HOST_TOOLS+=(${V3_HOST_TOOLS})
fi
# ...and from --host-tool flags (consume them out of "$@")
ARGS=()
while [ $# -gt 0 ]; do
  case "$1" in
    --host-tool) HOST_TOOLS+=("$2"); shift 2 ;;
    --host-tool=*) HOST_TOOLS+=("${1#*=}"); shift ;;
    *) ARGS+=("$1"); shift ;;
  esac
done
for t in "${HOST_TOOLS[@]}"; do
  p="$(command -v "$t" 2>/dev/null || true)"
  if [ -n "$p" ]; then
    # resolve symlinks so the real binary is mounted
    rp="$(readlink -f "$p" 2>/dev/null || echo "$p")"
    OPTS+=(-v "$rp:/usr/local/bin/$t:ro")
  fi
done

# ---- python venv ----
get_venv() {
  if [ -d ".venv" ]; then echo ".venv"; return; fi
  if command -v poetry >/dev/null 2>&1; then
    v=$(poetry env info --path 2>/dev/null | tail -n1 || true); [ -d "$v" ] && { echo "$v"; return; }
  fi
  if [ -n "${UV_PROJECT_ENVIRONMENT:-}" ]; then
    v="$UV_PROJECT_ENVIRONMENT"; case "$v" in /*) ;; *) v="$(pwd)/$v" ;; esac
    [ -d "$v" ] && { echo "$v"; return; }
  fi
  echo ""
}
VENV="$(get_venv)"
if [ -n "$VENV" ] && [ -d "$VENV" ]; then
  if [ "${VENV#/}" != "$VENV" ]; then
    # absolute venv (poetry/uv): mount it at its own path
    pydir=$(ls "$VENV/lib" 2>/dev/null | grep -m1 python || true)
    OPTS+=(-v "$VENV:$VENV" -e "VIRTUAL_ENV=$VENV")
    [ -n "$pydir" ] && OPTS+=(-e "PYTHONPATH=$VENV/lib/$pydir/site-packages")
  else
    # relative .venv rides the /x mount
    OPTS+=(-e "VIRTUAL_ENV=/x/$VENV")
  fi
fi

# ---- Copilot config (read-only; only if present) ----
COPILOT_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/github-copilot"
[ -d "$COPILOT_DIR" ] && OPTS+=(-v "$COPILOT_DIR:/home/myuser/.config/github-copilot:ro")

# ---- terminal capabilities (truecolor + undercurl from foot) ----
OPTS+=(-e "TERM=${TERM:-xterm-256color}" -e "COLORTERM=${COLORTERM:-truecolor}")

# ---- Doppler project secrets (ONE download) ----
if command -v doppler >/dev/null 2>&1; then
  DOPPLER_ENV="$(doppler secrets download --format env --no-file 2>/dev/null || true)"
  if [ -n "$DOPPLER_ENV" ]; then
    while IFS= read -r line; do [ -n "$line" ] && OPTS+=(-e "$line"); done <<< "$DOPPLER_ENV"
  fi
fi

# ---- git identity for in-container checkpoint commits (push/creds stay host) ----
GN="$(git config --get user.name 2>/dev/null || true)"
GE="$(git config --get user.email 2>/dev/null || true)"
[ -n "$GN" ] && OPTS+=(-e "GIT_AUTHOR_NAME=$GN" -e "GIT_COMMITTER_NAME=$GN")
[ -n "$GE" ] && OPTS+=(-e "GIT_AUTHOR_EMAIL=$GE" -e "GIT_COMMITTER_EMAIL=$GE")

exec "$DOCKER" run "${OPTS[@]}" "$DOCKER_IMAGE" "${ARGS[@]}"
