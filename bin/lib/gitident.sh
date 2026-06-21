# shellcheck shell=bash
# v3 module: git identity for in-container checkpoint commits.
# Contract: v3_gitident -> appends GIT_AUTHOR_*/GIT_COMMITTER_* env from the
# host's git config. Push/credentials stay HOST-side (the --rm container has no
# creds by design); this only lets you author commits inside the editor.

v3_gitident() {
  local n e
  n="$(git config --get user.name 2>/dev/null || true)"
  e="$(git config --get user.email 2>/dev/null || true)"
  [ -n "$n" ] && OPTS+=(-e "GIT_AUTHOR_NAME=$n" -e "GIT_COMMITTER_NAME=$n")
  [ -n "$e" ] && OPTS+=(-e "GIT_AUTHOR_EMAIL=$e" -e "GIT_COMMITTER_EMAIL=$e")
  return 0
}
