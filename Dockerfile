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

# for Avante
RUN apk add rust cargo

# For telescope
RUN apk add --no-cache fd

# For node and related packages
RUN apk add --no-cache nodejs npm uv
# tree-sitter-cli: use Alpine native package (npm version ships glibc binary)
RUN apk add --no-cache tree-sitter-cli
RUN npm i -g mcp-hub@latest claude

# LSP, CMP
# Add path so that we can exec the node modules from vim
ENV PATH="/root/.local/bin:./node_modules/.bin:$PATH"
RUN npm i -g typescript neovim
RUN apk add --no-cache bash # For lua LSP
RUN apk add --no-cache fzf # For telescope

# LSP servers that ship glibc binaries - install via apk for musl compatibility
RUN apk add --no-cache lua-language-server rust-analyzer


RUN adduser -D -u 1000 myuser
ENV HOME=/home/myuser
WORKDIR /home/myuser
RUN mkdir /home/myuser/.config

# Copy init.lua and stylua first (change rarely)
COPY init.lua $HOME/.config/nvim/init.lua
COPY stylua.toml $HOME/.config/nvim/stylua.toml

# Copy lua config (changes more often, but needed for Lazy install)
COPY lua $HOME/.config/nvim/lua

RUN chown 1000:1000 -R "$HOME"
USER 1000:1000

# Install all plugins via Lazy
RUN nvim --headless "+Lazy! install" +qall

# Build avante from source for Alpine Linux compatibility
# Use --mount=type=cache to persist Cargo build artifacts across rebuilds
RUN --mount=type=cache,target=/home/myuser/.cargo/registry,uid=1000,gid=1000 \
    --mount=type=cache,target=/home/myuser/.local/share/nvim/lazy/avante.nvim/build/.cargo,uid=1000,gid=1000 \
    cd /home/myuser/.local/share/nvim/lazy/avante.nvim && rm -rf build/* && make BUILD_FROM_SOURCE=true

RUN nvim --headless "+TSUpdate" +qall
RUN nvim --headless "+Lazy! sync" +qall
RUN nvim --headless "+MasonInstallAllPackages" +qall
RUN nvim --headless "+MasonInstallAllLsps" +qall


# Ugly fix https://github.com/tmux/tmux/issues/3983
ENV TMUX=foo

WORKDIR /x/

ENTRYPOINT ["nvim"]
