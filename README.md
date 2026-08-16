# docker-neovim — the fleet editor (`fwrlines/nvim3`)

A Neovim **0.12** configuration baked into a **glibc Ubuntu 26.04** OCI image,
launched per-project by a small shell verb so the editor is byte-identical across
machines. AI-light by design (Copilot-only, toggleable); project language tools
come from the **mounted working env**, not the image.

> Branch `refresh-2026` is the current line of work (Phases 0–2.5). The `lua`/
> `master`/`tidal` branches are older. See `df/session/NVIM/` for the full design
> record (assessment report, phase plans, decisions, verification).

## Launch

```bash
# one-time: build locally (until pushed to a registry)
docker build -f Dockerfile.base -t nvim-base:local .
docker build -t fwrlines/nvim3:local .

# alias the launcher, then use it from any project
alias v3="$PWD/bin/v3.sh"
cd ~/code/some-project && v3 src/main.ts
```

`v3` mounts `$(pwd)` at `/x`, auto-detects a Python venv, forwards terminal
truecolor, injects a git identity + Doppler secrets, and bind-mounts host-global
tools (sem-lsp, rust-analyzer) when present. See **`docs/LAUNCHER.md`** for the
full contract and flags (`--host-tool`, `V3_HOST_TOOLS`, `NVIM_IMAGE`,
`V3_DOCKER`).

## What's inside

- **Editor:** Neovim 0.12.3 (pinned tarball), **vim.pack** native plugin manager
  (no external manager), 15 plugins pinned via `nvim-pack-lock.json`.
- **Completion:** blink.cmp (Lua fuzzy, no binary) + Copilot as a toggleable
  source (`lua/config/ai.lua`).
- **LSP:** native 0.12 `lsp/` directory idiom. Baked, always-on: lua_ls,
  basedpyright (Python types), tsgo (TS7 native)/bashls/yamlls/jsonls/html/cssls (npm).
  Project/host tools (executable-guarded): ruff (venv), rust-analyzer + sem-lsp
  (host bind-mount).
- **Tools:** treesitter parsers baked at build time; stylua/shfmt baked;
  biome/prettier/eslint/ruff resolved from the project (`prefer_local`).
- **UI:** snacks (picker/explorer/input/notifier), gitsigns, lualine, which-key,
  trouble, iceberg colorscheme.
- **`:ToolStatus`** (`<leader>li`) reports, per buffer, which LSPs/formatters are
  active and where each resolved from.

## Image architecture

Two-stage, digest-pinned, multi-stage build:
- **`Dockerfile.base`** → `fwrlines/nvim-base`: heavy, rarely rebuilt — Ubuntu
  base, pinned toolchain tarballs, npm LSP servers, plugins restored from the
  lockfile, parsers baked. Compilers live only in the builder stage; the final
  stage ships none.
- **`Dockerfile`** → `fwrlines/nvim3`: thin — `FROM` the base, copies the config.
  A config edit rebuilds in **seconds**.

Build-time assertions fail the build if a tool is missing, a parser didn't bake,
the treesitter pin is wrong, or a compiler leaked into the final image.

## Tool source model

Drift-prone, project-versioned tools (biome, eslint, prettier, ruff, tsc,
rust-analyzer) come from the **host/project** (mount-from-env) so versions match
the project. Editor-infrastructure tools (nvim, treesitter, lua_ls, stylua,
shfmt, basedpyright) are **baked + pinned** so the image is a self-contained
editor anywhere. The base is **glibc** specifically so host-built native tools
run in the container. See `df/session/NVIM/TOOL-RESOLUTION-STORIES.md`.
