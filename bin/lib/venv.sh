# shellcheck shell=bash
# v3 module: Python virtualenv detection + mount.
# Contract: v3_venv  -> appends docker flags to the OPTS array (caller-declared).
#   * relative .venv rides the /x mount (only env vars set)
#   * absolute venv (poetry/uv) is bind-mounted at its own path
# The container also prepends $VIRTUAL_ENV/bin to PATH (lua/config/lsp.lua) so a
# venv-provided ruff resolves; here we only set VIRTUAL_ENV/PYTHONPATH + mount.

v3_detect_venv() {
  if [ -d ".venv" ]; then echo ".venv"; return; fi
  if command -v poetry >/dev/null 2>&1; then
    local v; v=$(poetry env info --path 2>/dev/null | tail -n1 || true)
    [ -d "$v" ] && { echo "$v"; return; }
  fi
  if [ -n "${UV_PROJECT_ENVIRONMENT:-}" ]; then
    local v="$UV_PROJECT_ENVIRONMENT"
    case "$v" in /*) ;; *) v="$(pwd)/$v" ;; esac
    [ -d "$v" ] && { echo "$v"; return; }
  fi
  echo ""
}

v3_venv() {
  local venv; venv="$(v3_detect_venv)"
  [ -n "$venv" ] && [ -d "$venv" ] || return 0
  if [ "${venv#/}" != "$venv" ]; then
    # absolute venv: mount at its own path
    local pydir; pydir=$(ls "$venv/lib" 2>/dev/null | grep -m1 python || true)
    OPTS+=(-v "$venv:$venv" -e "VIRTUAL_ENV=$venv")
    [ -n "$pydir" ] && OPTS+=(-e "PYTHONPATH=$venv/lib/$pydir/site-packages")
  else
    # relative .venv rides the /x mount
    OPTS+=(-e "VIRTUAL_ENV=/x/$venv")
  fi
}
