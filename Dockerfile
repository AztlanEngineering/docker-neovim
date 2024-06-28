#TEST
#FROM alpine:latest as builder
#COPY --from=builder /usr/bin/ /usr/bin

FROM alpine:latest
#FROM alpine:3.19

MAINTAINER fwrlines <hello@fwrlines.com>

RUN apk add --no-cache build-base neovim neovim-doc curl git

COPY init.lua /root/.config/nvim/init.lua
COPY plugins.lua /root/.config/nvim/plugins.lua

# Install Packer
RUN git clone --depth 1 https://github.com/wbthomason/packer.nvim \
    ~/.local/share/nvim/site/pack/packer/start/packer.nvim

WORKDIR /x/

ENTRYPOINT ["nvim"]
