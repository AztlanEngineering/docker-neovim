# The `v2()` launcher contract

This editor image (`fwrlines/nvim2`) is not run directly — it is launched by a
shell function `v2()` that composes the `docker run` invocation: it mounts the
project, injects a Python virtualenv, mounts the Copilot config and the
host-built `sem-lsp` binary, and passes secrets through as environment.

The canonical `v2()` currently lives in the **dotfiles repo** at
`df/config/zsh/aliases.sh`. This document is the image repo's source of truth
for **what that function must do** — the contract between image and host — so the
two can be kept in sync deliberately. Changes here are proposals to apply to the
dotfiles function; nothing here is auto-applied.

> Status: Phase 0 of the refresh-2026 plan. AI tooling (Avante, Claude Code,
> MCP) was removed from the image; Copilot remains as a toggleable completion
> source. Several launcher channels are affected — see **Phase 0 deltas** below.

---

## What `v2()` does today (verbatim behavior)

Invocation: `v2 [file ...]` — opens Neovim in the container with the current
directory mounted.

| # | Channel | Mechanism | Notes |
|---|---------|-----------|-------|
| 1 | Image | `DOCKER_IMAGE="fwrlines/nvim2"` | hardcoded (Phase 1 will read from `versions.env`) |
| 2 | Project | `-v "$(pwd):/x/"` | the project tree, read-write, mounted at `/x` |
| 3 | Base flags | `--rm -it` | ephemeral container; the sandbox boundary |
| 4 | Python venv | `get_venv` → mount + `VIRTUAL_ENV`/`PYTHONPATH` | absolute venvs (poetry/pipenv/uv) bind-mounted at their real path; relative `.venv` rides the `/x` mount |
| 5 | Copilot config | `-v ~/.config/github-copilot:/home/myuser/.config/github-copilot` | **read-write today** (see deltas) |
| 6 | Doppler secrets | `doppler secrets download` → one `-e` per secret | **downloaded twice today** (see deltas) |
| 7 | Anthropic key | `-e ANTHROPIC_API_KEY` from `~/.config/anthropic/api_key` | **now vestigial** — no in-image consumer after AI strip (see deltas) |
| 8 | sem-lsp binary | `-v ~/code/advl/sem/target/debug/sem-lsp:/usr/local/bin/sem-lsp:ro` | host-built; read-only; Phase 2 swaps to a musl release build |
| 9 | sem-lsp store | (none) — project-local at `/x/.sem/lmdb` | rides the `/x` mount |
| — | PipeWire/audio | commented-out block | for the `tidal` live-coding variant, not this image |
| — | Run | `docker run "${DOCKER_OPTS[@]}" $DOCKER_IMAGE "$@"` | |

Not crossing the boundary today (gaps): no `TERM`/`COLORTERM` passthrough (the
container gets `TERM=xterm`, so foot's truecolor/undercurl are understated); no
`.gitconfig` mount (in-container `git commit` has no identity); default bridge
network (host loopback unreachable).

---

## Phase 0 deltas (apply to the dotfiles `v2()`)

These are the launcher-side changes that pair with the Phase 0 image changes.
None is required for the image to *run*; they fix correctness/quality issues.

### D1 — Pass `TERM` / `COLORTERM` through (truecolor + undercurl)

The image sets `vim.o.termguicolors = true`, but the container never learns the
host terminal's capabilities. Forward them:

```sh
# add to DOCKER_OPTS, before the docker run:
DOCKER_OPTS+=(-e TERM="$TERM" -e COLORTERM="${COLORTERM:-truecolor}")
```

With foot on the host this makes 24-bit color and undercurl deterministic
instead of relying on runtime terminal probing. (The image also pairs this with
the removal of `ENV TMUX=foo`, which previously poisoned clipboard detection.)

### D2 — Download Doppler secrets once, not twice

Today the secrets are downloaded once to test, then **again** to use — doubling
latency and the network dependency on every launch. Collapse to one call:

```sh
# replace the download-twice block:
DOPPLER_ENV=$(doppler secrets download --format env --no-file 2>/dev/null || true)
if [ -n "$DOPPLER_ENV" ]; then
  while IFS= read -r line; do
    DOCKER_OPTS+=(-e "$line")
  done <<< "$DOPPLER_ENV"
fi
```

### D3 — Mount the Copilot config read-only

Copilot needs only to *read* its credentials; a read-write mount lets anything
in the container rewrite the host's GitHub OAuth tokens. Add `:ro`:

```sh
if [ -d "$XDG_CONFIG_HOME/github-copilot" ]; then
  DOCKER_OPTS+=(-v "$XDG_CONFIG_HOME/github-copilot:/home/myuser/.config/github-copilot:ro")
fi
```

This mount stays only while Copilot is enabled (`lua/config/ai.lua`,
`enable_copilot = true`). If Copilot is toggled off, the mount is harmless but
unnecessary.

### D4 — `ANTHROPIC_API_KEY` injection is now vestigial

With Avante and Claude Code removed from the image, nothing in the container
consumes `ANTHROPIC_API_KEY`. The injection block can be **removed** from
`v2()` — it currently exposes a key in the container env for no reason.

> Keep it only if you intend to re-add an Anthropic-backed tool in the AI
> follow-up phase; otherwise delete it now and re-add deliberately later. The AI
> follow-up will define how agent auth crosses the boundary (likely a mounted
> credential dir, not a plaintext `-e`).

---

## Deferred to later phases (recorded so they aren't lost)

- **Phase 1** — read the image name + digest from `core/versions.env`
  (`DOCKER_IMAGE="$(grep NVIM_IMAGE …)"`) instead of hardcoding `fwrlines/nvim2`;
  this is what makes the fleet's digest-pinning real on the launch side.
- **Phase 2** — point the sem-lsp mount at the musl *release* build once it
  exists, and drop `gcompat` from the image.
- **Persistence phase** — if snacks frecency / recent-files / undo history are
  wanted across `--rm`, add the relevant host-state mounts here (deferred by
  decision; snacks currently accepts per-session reset).
- **Quality** — `.gitconfig` (read-only) + `GIT_AUTHOR_*`/`GIT_COMMITTER_*` for
  in-container checkpoint commits; a no-git-repo guard; `file:line` open syntax.
