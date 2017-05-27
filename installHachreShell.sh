#!/bin/bash

wget -O hachretmp.sh https://raw.githubusercontent.com/hachre/aliases/master/source/aliases.sh
source hachretmp.sh
dyi git zsh curl byobu mosh
curl -fsSL https://raw.githubusercontent.com/hachre/aliases/master/install.sh | bash
if [ -f "$HOME/.zshrc" ]; then
	rm "$HOME/.zshrc" 1>/dev/null 2>&1
	rm "$HOME/.zshrc_grml" 1>/dev/null 2>&1
fi
echo "source \"$HOME/.zshrc_grml\"" >> "$HOME/.zshrc"
echo "emulate sh -c \"source /usr/local/hachre/aliases/source/aliases.sh\"" >> "$HOME/.zshrc"
echo "echo \"Welcome :)\"" >> "$HOME/.zshrc"
cd "$HOME"
wget -O .zshrc_grml http://git.grml.org/f/grml-etc-core/etc/zsh/zshrc
chsh -s `which zsh`
clear
echo "Starting hachreShell environment..."
zsh -c "byobu-enable"
