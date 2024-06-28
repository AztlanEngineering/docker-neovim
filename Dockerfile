#TEST
#FROM alpine:latest as builder
#COPY --from=builder /usr/bin/ /usr/bin

FROM alpine:latest
#FROM alpine:3.19

MAINTAINER fwrlines <hello@fwrlines.com>


RUN apk add --no-cache build-base neovim neovim-doc curl git


ENTRYPOINT ["nvim"]
