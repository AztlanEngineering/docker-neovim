# shellcheck shell=bash
# v3 module: forward terminal capabilities so the containerized nvim gets
# truecolor + undercurl from the host terminal (foot). Without this the container
# sees TERM=xterm and understates the terminal.
# Contract: v3_term -> appends -e TERM/-e COLORTERM to OPTS.

v3_term() {
  OPTS+=(-e "TERM=${TERM:-xterm-256color}" -e "COLORTERM=${COLORTERM:-truecolor}")
}
