#!/bin/bash

wget -q https://raw.githubusercontent.com/hachre/aliases/master/install.sh
bash install.sh
rm install.sh
source /usr/local/hachre/aliases/source/aliases.sh

dyx
dyi -y git
dyi -y zsh
dyi -y byobu
dyi -y mosh
dyi -y htop
dyi -y zstd
rehash 1>/dev/null 2>&1

cd /usr/local/hachre/aliases
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git

cd /tmp
wget -q https://raw.githubusercontent.com/hachre/aliases/master/root-skel.tar.zstd
zstd -d root-skel.tar.zstd && rm root-skel.tar.zstd
cd /root
tar xvf /tmp/root-skel.tar
rm /tmp/root-skel.tar

chsh -s `which zsh`

echo "Almost done! Please logout and back in to your shell"
echo "and run 'byobu-enable' followed by 'byobu' to finish."

zsh


