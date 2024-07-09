# Dckerfile

FROM alpine:latest

MAINTAINER fwrlines <hello@fwrlines.com>

RUN apk add --no-cache python3 
RUN apk add --no-cache py3-pynvim 

RUN apk add --no-cache \
    neovim \
    neovim-doc \
    curl \
    git 

RUN apk add --no-cache build-base # GCC + Make, requried for FZF ext

# https://wiki.alpinelinux.org/wiki/GCC, required for pynvim
RUN apk add --no-cache gcc musl-dev 

# For luarocks compatibility with lazy
RUN apk add --no-cache lua5.1 lua5.1-dev luarocks 
RUN apk add --no-cache ripgrep 
RUN luarocks-5.1 install luarocks 

# For telescope
RUN apk add --no-cache fd 

# For node and related packages 
RUN apk add --no-cache nodejs npm 
RUN npm i -g tree-sitter-cli 

# LSP, CMP
# Add path so that we canexec the node modules from vim
ENV PATH="/root/.local/bin:./node_modules/.bin:$PATH"
RUN npm i -g typescript neovim
RUN apk add --no-cache bash # For lua LSP
RUN apk add --no-cache fzf # For telescope


# Final setup and install
COPY init.lua /root/.config/nvim/init.lua
COPY lua /root/.config/nvim/lua
COPY stylua.toml /root/.config/nvim/stylua.toml

RUN nvim --headless "+Lazy! install" +qall  
RUN nvim --headless "+TSUpdateSync" +qall 
RUN nvim --headless "+Lazy! sync" +qall 
RUN nvim --headless "+MasonInstallAllPackages" +qall
RUN nvim --headless "+MasonInstallAllLsps" +qall


# Ugly fix https://github.com/tmux/tmux/issues/3983
ENV TMUX=foo

WORKDIR /x/
RUN git config --global --add safe.directory /x 

ENTRYPOINT ["nvim"]
