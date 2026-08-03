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
# Override the OCI labels inherited from the Ubuntu base so the GHCR package
# page describes THIS editor, not Ubuntu. source= links the package to the repo.
LABEL org.opencontainers.image.title="nvim3" \
      org.opencontainers.image.description="fwrlines fleet editor — Neovim 0.12 (glibc), AI-light, project-tool-aware" \
      org.opencontainers.image.source="https://github.com/AztlanEngineering/docker-neovim" \
      org.opencontainers.image.revision="${GIT_SHA}" \
      org.opencontainers.image.licenses="MIT"

# tmux CLIENT only — the vim-tidal bridge ([tidal-rig] L3) talks to the HOST
# tmux server through the socket `v3 --tidal` mounts; no server runs in here.
# Ubuntu's tmux vs the host's nixpkgs tmux is an ACCEPTED version-skew risk
# (ratified over mounting /nix/store:ro) — recheck at every image refresh.
USER root
RUN apt-get update && apt-get install -y --no-install-recommends tmux \
 && rm -rf /var/lib/apt/lists/*

USER 1000:1000
WORKDIR /home/myuser

# Replace (not overlay) the config so a DELETED spec/keymap file from the base
# snapshot does not linger.
RUN rm -rf /home/myuser/.config/nvim/lua /home/myuser/.config/nvim/init.lua

# COPY order is irrelevant for caching here (last layers). nvim-pack-lock.json is
# copied so the thin sync pins against the SAME lock as the base.
COPY --chown=1000:1000 init.lua stylua.toml nvim-pack-lock.json /home/myuser/.config/nvim/
# The LSP registry lands in the CONFIG dir, not /tmp. Dockerfile.base copies it
# too, but only to derive the npm pins, and deletes it in the same layer — this
# copy is the RUNTIME one that lua/config/lsp.lua reads for prefer_local
# resolution. Same file, vendored from df's nix/lsp/servers.json; the base uses
# it at build time, the thin at run time.
COPY --chown=1000:1000 lsp-servers.json /home/myuser/.config/nvim/lsp-servers.json
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

# stylua gate (drive-by): the full config must pass the repo's own stylua.toml.
# Here (not in base) because lsp/ + after/ ship only in the thin image.
RUN cd /home/myuser/.config/nvim \
 && stylua --check init.lua lua lsp after \
 || { echo 'ASSERT FAIL: stylua --check failed (lua drifted from stylua.toml)'; exit 1; }

# Smoke: the full real config (options/keymaps/preferences) loads headless.
RUN nvim --headless "+lua print('config ok')" +qall

# LSP-ATTACH assertion (drive-by): prove lua_ls actually ATTACHES (not just that
# the binary exists — would have caught the root-owned-metapath crash). Real
# config lives here (the base ships stubs), so the enable + attach happen.
RUN printf 'local x = 1\n' > /tmp/probe.lua \
 && nvim --headless /tmp/probe.lua -c 'lua \
      local ok = vim.wait(25000, function() return #vim.lsp.get_clients({ bufnr = 0, name = "lua_ls" }) > 0 end, 200); \
      if not ok then io.stderr:write("ASSERT FAIL: lua_ls did not attach\n"); vim.cmd("cquit 1") end; \
      vim.cmd("qa")' \
 && rm /tmp/probe.lua

# Restore the project workdir. A child WORKDIR in this stage (above) overrides
# the base's, so it must be set again explicitly — it is NOT inherited once
# overridden. ENTRYPOINT ["nvim"] IS inherited from the base.
WORKDIR /x/
