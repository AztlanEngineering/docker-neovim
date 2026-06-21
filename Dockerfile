# syntax=docker/dockerfile:1.7
########################################################################
# fwrlines/nvim3 — the editor the fleet pulls. Rebuilds in SECONDS.
#
# Built FROM the heavy base (Dockerfile.base). Only the config layer changes
# here, so a keymap/option/behavior edit is a seconds-long rebuild.
#
# BASE pin: until the base is pushed to GHCR, build the base locally first
#   docker build -f Dockerfile.base -t nvim-base:local .
# and this FROM resolves to it. After the GHCR push workstream, replace with
#   FROM ghcr.io/fwrlines/nvim-base@sha256:<BASE_DIGEST>
# so the fleet pulls a digest-pinned base. (TODO: GHCR push + versions.env.)
########################################################################
ARG BASE_IMAGE=nvim-base:local
FROM ${BASE_IMAGE}
ARG GIT_SHA=unknown
LABEL org.opencontainers.image.revision="${GIT_SHA}"

USER 1000:1000
WORKDIR /home/myuser

# Replace (not overlay) the config so a DELETED spec/keymap file from the base
# snapshot does not linger.
RUN rm -rf /home/myuser/.config/nvim/lua /home/myuser/.config/nvim/init.lua

# COPY order is irrelevant for caching here (last layers). nvim-pack-lock.json is
# copied so the thin sync pins against the SAME lock as the base.
COPY --chown=1000:1000 init.lua stylua.toml nvim-pack-lock.json /home/myuser/.config/nvim/
COPY --chown=1000:1000 lua /home/myuser/.config/nvim/lua
# Native LSP config dirs (outside lua/): the lsp/ bespoke servers + after/lsp/
# overrides. Real content lands here (base only had the stub lsp.lua).
COPY --chown=1000:1000 lsp /home/myuser/.config/nvim/lsp
COPY --chown=1000:1000 after /home/myuser/.config/nvim/after

# Delta plugin sync against the base's already-populated store (vim.pack):
#   * opts/keymap-only edit -> add() is a no-op (lock unchanged, plugins present)
#   * pure-lua plugin ADD   -> add() clones the new one (blocking) at its version
#   * plugin REMOVED        -> rebuild the BASE (vim.pack has no auto-clean; the
#     base's data copy regenerates without it). Removals are rare; this keeps the
#     thin image free of del-logic. A plugin with a NATIVE build also = base rebuild.
RUN nvim --headless \
      -c 'lua require("config.plugins")' \
      -c 'lua vim.pack.update(nil, { force = true, target = "lockfile" })' \
      -c 'qa'

# Smoke: the full real config (options/keymaps/preferences) loads headless.
RUN nvim --headless "+lua print('config ok')" +qall

# Restore the project workdir. A child WORKDIR in this stage (above) overrides
# the base's, so it must be set again explicitly — it is NOT inherited once
# overridden. ENTRYPOINT ["nvim"] IS inherited from the base.
WORKDIR /x/
