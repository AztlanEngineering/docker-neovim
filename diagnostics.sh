#!/bin/bash

echo "Diagnostic Information:"
echo "========================"
echo "TERM: $TERM"
echo "SHELL: $SHELL"
echo "TMUX: $TMUX"
echo "========================"

echo "Running Neovim standalone..."
nvim --version

echo "Listing environment variables..."
env

echo "Checking installed packages..."
apk info

echo "Listing terminal capabilities..."
infocmp

echo "Testing Neovim with verbose logging..."
#nvim -V3logfile +qall
