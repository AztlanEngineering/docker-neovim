# shellcheck shell=bash
# v3 module: TidalCycles editor bridge ([tidal-rig] L3 — canonical spec in df
# docs/notes/tidal-rig.md; opt-in: `v3 --tidal` or V3_TIDAL=1). Mounts the
# HOST tmux socket dir so the baked tmux CLIENT (Dockerfile) can send-keys
# into the rig session that df's tools/tidal owns (windows sc + repl).
# Default-off: zero cost and zero widened surface when unused. uid mapping is
# NOT this module's job — the launcher's global keep-id block already makes
# container uid 1000 == the socket owner under rootless podman.

v3_tidal() {
  [ "${V3_TIDAL:-0}" = 1 ] || return 0
  # TMUX_TMPDIR is the PARENT: tmux puts sockets at $TMUX_TMPDIR/tmux-$UID
  # (NixOS sets TMUX_TMPDIR=/run/user/$UID; bare /tmp elsewhere).
  local sockdir="${TMUX_TMPDIR:-/tmp}/tmux-$(id -u)"
  if [ ! -S "$sockdir/default" ]; then
    echo "v3: --tidal: no tmux socket at $sockdir/default — boot the rig first (\`tidal\`)" >&2
    exit 2
  fi
  # The container runs uid 1000 with no TMUX_TMPDIR, so its tmux looks at
  # /tmp/tmux-1000 — mount the host dir exactly there.
  OPTS+=(-v "$sockdir:/tmp/tmux-1000")
  return 0
}
