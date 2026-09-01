# shellcheck shell=bash
# v3 module: per-tool opt-in bind-mount of host-global binaries.
# Contract: v3_host_tools  -> appends docker flags to OPTS for each resolvable
#   tool in the V3_HOST_TOOL_LIST array (caller builds it from the default set +
#   --host-tool flags + V3_HOST_TOOLS env). glibc image => host binaries run
#   natively. NOT a blanket ~/.local/bin mount (sandbox stays controlled).

# The host tool's own ELF closure, as store roots (`/nix/store/<name>`), one per
# line. A NIX-BUILT binary hardcodes its interpreter and RUNPATH into the store
# ("/nix/store/…-glibc-…/lib/ld-linux-x86-64.so.2"); nothing of that exists in
# the image, so execve() fails with ENOENT and the mounted tool is a LIE — the
# editor reports "language server … not installed, missing from PATH, or not
# executable" on every single file open, and the tool never runs. `ldd` performs
# the loader's own resolution, so its output IS the exact set the binary needs;
# each printed path is also resolved through readlink because nixpkgs' lib dirs
# are full of symlinks ACROSS store paths (libgcc_s.so.1 -> …-libgcc/lib/…).
# Nothing here on a non-nix host: no /nix lines, no extra mounts.
v3_nix_closure() {
  command -v ldd >/dev/null 2>&1 || return 0
  ldd "$1" 2>/dev/null | grep -o '/nix/store/[^ )]*' | while read -r lib; do
    printf '%s\n' "$lib"
    readlink -f "$lib" 2>/dev/null
  done | grep '^/nix/store/' | cut -d/ -f1-4 | sort -u
  return 0
}

v3_host_tools() {
  local t p rp r mounted="" roots="" seen=""
  for t in "${V3_HOST_TOOL_LIST[@]}"; do
    p="$(command -v "$t" 2>/dev/null || true)"
    [ -n "$p" ] || continue
    rp="$(readlink -f "$p" 2>/dev/null || echo "$p")"   # mount the real binary
    OPTS+=(-v "$rp:/usr/local/bin/$t:ro")
    # ALSO mount the tool's directory: a FILE bind-mount pins the inode at
    # container start, so a host-side rename-swap (the atomic install ritual)
    # never reaches a running container. A DIRECTORY mount resolves names at
    # open() time — /opt/hosttools/<t>.d/<t> is always the CURRENT host build,
    # picked up by any newly spawned process (e.g. :LspRestart), no relaunch.
    OPTS+=(-v "$(dirname "$rp"):/opt/hosttools/$t.d:ro")
    roots="$roots $(v3_nix_closure "$rp" || true)"
    mounted="${mounted:+$mounted }$t"
  done
  # …and the closure those binaries were LINKED against, read-only at its own
  # paths, so "host binaries run natively" is true instead of aspirational.
  # Deliberately NOT `-v /nix/store:/nix/store:ro`: this is the tool's own
  # closure (3 store paths for sem-lsp) — the sandbox stays controlled, and the
  # set follows the host toolchain automatically at every launch.
  # `--mount` and not `-v`: podman MANGLES a `-v src:dst:ro` whose destination
  # contains dots (…-glibc-2.42-67 lands as …-glibc-2o, measured), and the
  # interpreter path must be byte-exact or the loader is not found at all.
  for r in $roots; do
    case " $seen " in *" $r "*) continue ;; esac
    [ -d "$r" ] || continue
    seen="$seen $r"
    OPTS+=(--mount "type=bind,source=$r,destination=$r,readonly")
  done
  # Typed-mounts metadata: DECLARE which /usr/local/bin entries are host mounts,
  # so in-container tooling (:ToolStatus, df-check) classifies origins exactly
  # instead of inferring from paths (host mounts are otherwise indistinguishable
  # from baked binaries).
  [ -n "$mounted" ] && OPTS+=(-e "V3_ORIGIN_HOST_TOOLS=$mounted")
  return 0
}
