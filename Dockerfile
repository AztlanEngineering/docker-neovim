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

COPY init.lua /root/.config/nvim/init.lua
COPY lua /root/.config/nvim/lua
COPY stylua.toml /root/.config/nvim/stylua.toml

RUN nvim --headless "+Lazy! install" +qall  
RUN nvim --headless "+TSUpdateSync" +qall 
RUN nvim --headless "+Lazy! sync" +qall 

# Ugly fix https://github.com/tmux/tmux/issues/3983
ENV TMUX=foo

WORKDIR /x/
RUN git config --global --add safe.directory /x 

ENTRYPOINT ["nvim"]
