#!/bin/bash

wget -q https://raw.githubusercontent.com/hachre/aliases/master/source/aliases.sh
source aliases.sh
rm aliases.sh

if [ "$dyDetectedDistro" == "CentOS" ]; then
	yum install -y epel-release || true
	yum-config-manager --enable epel || true
fi

dyx || true
dyi -y git zsh byobu mosh htop aria2 zstd
rehash 1>/dev/null 2>&1

wget -q https://raw.githubusercontent.com/hachre/aliases/master/install.sh
bash install.sh
rm install.sh
source /usr/local/hachre/aliases/source/aliases.sh

cd /usr/local/hachre/aliases
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git

cd /usr/local/
git clone https://github.com/craigbarnes/dte.git
cd dte
git checkout v1.6
dyi -y build-essential ncurses5-dev
make -j 4
make install

cd /tmp
wget -q https://raw.githubusercontent.com/hachre/aliases/master/root-skel.tar.gz
cd /root
tar xvzf /tmp/root-skel.tar.gz && rm /tmp/root-skel.tar.gz
echo "export EDITOR=dte" >> /root/.zshrc
echo "alias nano=dte" >> /root/.zshrc

chsh -s `which zsh`

echo "Almost done! Please logout and back in to your shell"
echo "and run 'byobu-enable' followed by 'byobu' to finish."
sleep 1
logout
