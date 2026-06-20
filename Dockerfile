# Dockerfile

FROM alpine:latest

LABEL maintainer="fwrlines <hello@fwrlines.com>"

RUN apk add --no-cache python3
RUN apk add --no-cache py3-pynvim

RUN apk add --no-cache \
    neovim \
    neovim-doc \
    curl \
    git

RUN apk add --no-cache build-base # GCC + Make, required for FZF ext

# https://wiki.alpinelinux.org/wiki/GCC, required for pynvim
RUN apk add --no-cache gcc musl-dev

# For luarocks compatibility with lazy
RUN apk add --no-cache lua5.1 lua5.1-dev luarocks
RUN apk add --no-cache ripgrep
RUN luarocks-5.1 install luarocks

# For telescope
RUN apk add --no-cache fd

# For node and related packages
RUN apk add --no-cache nodejs npm uv
# tree-sitter-cli: use Alpine native package (npm version ships glibc binary)
RUN apk add --no-cache tree-sitter-cli

# LSP, CMP
# Add path so that we can exec the node modules from vim
ENV PATH="/root/.local/bin:./node_modules/.bin:$PATH"
RUN npm i -g typescript neovim
RUN apk add --no-cache bash # For lua LSP
RUN apk add --no-cache fzf # For telescope

# LSP servers that ship glibc binaries - install via apk for musl compatibility
RUN apk add --no-cache lua-language-server rust-analyzer

# gcompat: glibc compatibility layer for host-built binaries (e.g. sem-lsp)
RUN apk add --no-cache gcompat


RUN adduser -D -u 1000 myuser
ENV HOME=/home/myuser
WORKDIR /home/myuser
RUN mkdir -p /home/myuser/.config/nvim/lua/config

# Copy init.lua and stylua (rarely change)
COPY init.lua $HOME/.config/nvim/init.lua
COPY stylua.toml $HOME/.config/nvim/stylua.toml

# Copy lazy bootstrap and plugin specs (trigger full install on change)
COPY lua/config/lazy.lua $HOME/.config/nvim/lua/config/lazy.lua
# ai.lua is required BY the plugin specs (toggle read at spec-parse), so it
# needs real content here, not a stub. It changes rarely.
COPY lua/config/ai.lua $HOME/.config/nvim/lua/config/ai.lua
COPY lua/plugins $HOME/.config/nvim/lua/plugins

# Create stubs for config files required by init.lua
# (real files are copied later to avoid cache-busting heavy installs)
RUN touch $HOME/.config/nvim/lua/config/options.lua \
          $HOME/.config/nvim/lua/config/autocmds.lua \
          $HOME/.config/nvim/lua/config/keymaps.lua \
          $HOME/.config/nvim/lua/config/preferences.lua

RUN chown 1000:1000 -R "$HOME"
USER 1000:1000

# Install all plugins via Lazy
RUN nvim --headless "+Lazy! install" +qall

RUN nvim --headless "+TSUpdate" +qall
RUN nvim --headless "+Lazy! sync" +qall
RUN nvim --headless "+MasonInstallAllPackages" +qall
RUN nvim --headless "+MasonInstallAllLsps" +qall

# (clipboard) ENV TMUX=foo removed: it poisoned OSC52 clipboard detection.
# Clipboard provider is configured explicitly in lua; TERM/COLORTERM come
# through v2() so foot's truecolor + OSC52 work.

# Copy config files last (change most often, no heavy rebuild needed)
COPY --chown=1000:1000 lua/config/options.lua $HOME/.config/nvim/lua/config/options.lua
COPY --chown=1000:1000 lua/config/keymaps.lua $HOME/.config/nvim/lua/config/keymaps.lua
COPY --chown=1000:1000 lua/config/autocmds.lua $HOME/.config/nvim/lua/config/autocmds.lua
COPY --chown=1000:1000 lua/config/preferences.lua $HOME/.config/nvim/lua/config/preferences.lua

WORKDIR /x/

ENTRYPOINT ["nvim"]
