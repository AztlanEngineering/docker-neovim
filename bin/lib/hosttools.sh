# shellcheck shell=bash
# v3 module: per-tool opt-in bind-mount of host-global binaries.
# Contract: v3_host_tools  -> appends docker flags to OPTS for each resolvable
#   tool in the V3_HOST_TOOL_LIST array (caller builds it from the default set +
#   --host-tool flags + V3_HOST_TOOLS env). glibc image => host binaries run
#   natively. NOT a blanket ~/.local/bin mount (sandbox stays controlled).

v3_host_tools() {
  local t p rp mounted=""
  for t in "${V3_HOST_TOOL_LIST[@]}"; do
    p="$(command -v "$t" 2>/dev/null || true)"
    [ -n "$p" ] || continue
    rp="$(readlink -f "$p" 2>/dev/null || echo "$p")"   # mount the real binary
    OPTS+=(-v "$rp:/usr/local/bin/$t:ro")
    mounted="${mounted:+$mounted }$t"
  done
  # Typed-mounts metadata: DECLARE which /usr/local/bin entries are host mounts,
  # so in-container tooling (:ToolStatus, df-check) classifies origins exactly
  # instead of inferring from paths (host mounts are otherwise indistinguishable
  # from baked binaries).
  [ -n "$mounted" ] && OPTS+=(-e "V3_ORIGIN_HOST_TOOLS=$mounted")
}
