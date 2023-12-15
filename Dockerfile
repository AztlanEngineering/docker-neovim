#TEST
#FROM alpine:latest as builder
#COPY --from=builder /usr/bin/ /usr/bin

FROM alpine:latest

MAINTAINER fwrlines <hello@fwrlines.com>

RUN apk add --no-cache build-base neovim neovim-doc curl git

RUN mkdir /etc/nvim/

COPY vimrc /root/.config/nvim/init.vim

RUN curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

#Run PlugInstall to the end

WORKDIR /x/
#FROM alpine:latest

#Required for vim plugins below
RUN apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/community fzf the_silver_searcher
RUN apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/community bat
RUN apk add --no-cache tidyhtml yamllint shellcheck bash
ENV FZF_DEFAULT_COMMAND='ag --nocolor -g ""'
ENV FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
ENV FZF_ALT_C_COMMAND="$FZF_DEFAULT_COMMAND"
ENV FZF_DEFAULT_OPTS='\
  --color fg:242,bg:236,hl:65,fg+:15,bg+:239,hl+:108\
  --color info:108,prompt:109,spinner:108,pointer:168,marker:168'
ENV PATH="/virtualenv/bin:$PATH"

RUN mkdir -p "$(bat --config-dir)/themes"
RUN curl -fLo "$(bat --config-dir)/themes/iceberg.tmTheme" \
    https://raw.githubusercontent.com/daylerees/colour-schemes/master/sublime/iceberg.tmTheme
RUN bat cache --build

ENV BAT_THEME=iceberg

# We add node to be able to execure JS and Linting binaries
RUN apk add --no-cache nodejs npm
RUN npm i -g typescript neovim

#Add path so that we canexec the node modules from vim
ENV PATH="./node_modules/.bin:$PATH"
#The following is only needed for deoplete
# — https://github.com/Docker-Hub-frolvlad/docker-alpine-python3/blob/master/Dockerfile
ENV PYTHONUNBUFFERED=1

#
ENV PROJECT_HOME="/x"
RUN echo "**** install Python ****" && \
    apk add --no-cache python3 py3-pip && \
    if [ ! -e /usr/bin/python ]; then ln -sf python3 /usr/bin/python ; fi && \
    \
    pip3 install --no-cache --break-system-packages --upgrade pip setuptools wheel && \
    if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi
RUN apk add --no-cache gcc python3-dev musl-dev

RUN pip3 install --user --break-system-packages pynvim

RUN apk del gcc python3-dev musl-dev

RUN nvim +PlugInstall +qall
RUN nvim +UpdateRemotePlugins +qall

ENTRYPOINT ["nvim"]
