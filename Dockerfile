# Dckerfile

FROM alpine:latest

MAINTAINER fwrlines <hello@fwrlines.com>

RUN apk add --no-cache \
    neovim \
    neovim-doc \
    curl \
    git 

COPY init.lua /root/.config/nvim/init.lua
COPY plugins.lua /root/.config/nvim/plugins.lua

# Install Packer
RUN git clone --depth 1 https://github.com/wbthomason/packer.nvim \
    ~/.local/share/nvim/site/pack/packer/start/packer.nvim

RUN nvim --headless +PackerSync +qall

# Ugly fix https://github.com/tmux/tmux/issues/3983
ENV TMUX=foo

WORKDIR /x/

ENTRYPOINT ["nvim"]
