#TEST
#FROM alpine:latest as builder
#COPY --from=builder /usr/bin/ /usr/bin

FROM alpine:latest

MAINTAINER fwrlines <hello@fwrlines.com>

RUN apk add --no-cache neovim neovim-doc curl git



RUN mkdir /etc/nvim/

COPY vimrc /etc/nvim/.vimrc

RUN curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

RUN nvim -u /etc/nvim/.vimrc +PlugInstall +qall

WORKDIR /x/
#FROM alpine:latest

#Required for vim plugins below
RUN apk add --no-cache fzf the_silver_searcher
ENV FZF_DEFAULT_COMMAND='ag --nocolor -g ""'
ENV FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
ENV FZF_ALT_C_COMMAND="$FZF_DEFAULT_COMMAND"
ENV FZF_DEFAULT_OPTS='\
  --color fg:242,bg:236,hl:65,fg+:15,bg+:239,hl+:108\
  --color info:108,prompt:109,spinner:108,pointer:168,marker:168\
  '

#Add runtime libs

ENTRYPOINT ["nvim", "-u", "/etc/nvim/.vimrc"]
