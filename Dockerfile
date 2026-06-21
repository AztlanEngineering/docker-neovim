# syntax=docker/dockerfile:1.7
########################################################################
# fwrlines/nvim2 — the editor the fleet pulls. Rebuilds in SECONDS.
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

# COPY order is irrelevant for caching here (last layers). lazy-lock.json is
# copied so the thin restore pins against the SAME lock as the base.
COPY --chown=1000:1000 init.lua stylua.toml lazy-lock.json /home/myuser/.config/nvim/
COPY --chown=1000:1000 lua /home/myuser/.config/nvim/lua
# Native LSP config dirs (outside lua/): the lsp/ bespoke servers + after/lsp/
# overrides. Real content lands here (base only had the stub lsp.lua).
COPY --chown=1000:1000 lsp /home/myuser/.config/nvim/lsp
COPY --chown=1000:1000 after /home/myuser/.config/nvim/after

# Delta plugin sync against the base's already-populated store:
#   * keymap/option/opts-only edit -> restore is a no-op (lockfile unchanged)
#   * pure-lua plugin ADD           -> install clones it; restore pins it
#   * plugin REMOVED from spec       -> clean deletes it
# A plugin with a NATIVE build hook would fail here (no compiler) — that failure
# is the signal to rebuild the base instead. (Today only treesitter builds, and
# it is already baked in the base, so this stays fast.)
RUN nvim --headless "+Lazy! install" "+Lazy! restore" "+Lazy! clean" +qall

# Smoke: the full real config (options/keymaps/preferences) loads headless.
RUN nvim --headless "+lua print('config ok')" +qall

# Restore the project workdir. A child WORKDIR in this stage (above) overrides
# the base's, so it must be set again explicitly — it is NOT inherited once
# overridden. ENTRYPOINT ["nvim"] IS inherited from the base.
WORKDIR /x/
