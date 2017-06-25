#!/bin/bash

wget -O hachretmp.sh https://raw.githubusercontent.com/hachre/aliases/master/source/aliases.sh
if [ "$?" != "0" ]; then
	echo "Something went wrong while downloading the hachreShell prequisites."
	exit 1
fi
source hachretmp.sh
rm hachretmp.sh

dyi git zsh curl byobu mosh

curl -fsSL https://raw.githubusercontent.com/hachre/aliases/master/install.sh | bash
if [ -f "$HOME/.zshrc" ]; then
	rm "$HOME/.zshrc" 1>/dev/null 2>&1
	rm "$HOME/.zshrc_grml" 1>/dev/null 2>&1
	rm "$HOME/.zshrc_fish" 1>/dev/null 2>&1
fi

echo "source \"$HOME/.zshrc_grml\"" >> "$HOME/.zshrc"
echo "source \"/usr/local/hachre/aliases/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh\"" >> "$HOME/.zshrc"
echo "emulate sh -c \"source /usr/local/hachre/aliases/source/aliases.sh\"" >> "$HOME/.zshrc"
echo "echo \"Welcome :)\"" >> "$HOME/.zshrc"
cd "$HOME"

wget -O .zshrc_grml http://git.grml.org/f/grml-etc-core/etc/zsh/zshrc

cd /usr/local/hachre/aliases
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git

rehash 1>/dev/null 2>&1

chsh -s `which zsh`
echo "Almost done! Please logout and back in to your shell"
echo "and run 'byobu-enable' followed by 'byobu' to finish."