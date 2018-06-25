#!/bin/bash
#
# 1.0.20180624.1
#

if [ $(whoami) != "root" ]; then
	echo "Error: This setup needs to be run as root."
	exit 1
fi

which wget 1>/dev/null 2>&1
if [ "$?" != "0" ]; then
	echo "Error: We need 'wget' to be installed."
	exit 1
fi

# Load hachreAliases
rm -R /usr/local/hachre/aliases 1>/dev/null 2>&1
cd /tmp
wget -q https://raw.githubusercontent.com/hachre/aliases/master/source/aliases.sh
source aliases.sh

# CentOS specific prequisities
if [ "$dyDetectedDistro" == "CentOS" ]; then
	yum install -y epel-release || true
	yum-config-manager --enable epel || true
fi

# Set the noconfirm flag based on the distro in use
noconfirm=""
if [ "$dyDetectedDistro" == "CentOS" ]; then
	noconfirm="-y"
fi
if [ "$dyDetectedDistro" == "arch" ]; then
	noconfirm="--noconfirm"
fi
if [ "$dyDetectedDistro" == "ubuntu" ]; then
	noconfirm="-y"
fi

# Install the prequisites we'd like to have
dyx || true
dyi "$noconfirm" git zsh mosh htop aria2 curl nano sudo
dyi "$noconfirm" byobu
rehash 1>/dev/null 2>&1

# Install hachreAliases
cd /tmp
wget -q https://raw.githubusercontent.com/hachre/aliases/master/install.sh
bash install.sh
rm install.sh
source /usr/local/hachre/aliases/source/aliases.sh

# Install zsh syntax highlighting
cd /usr/local/hachre/aliases
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git

# Install nano syntax highlighting
cd /usr/local/hachre/aliases
git clone https://github.com/scopatz/nanorc.git nano-syntax-highlighting
cat /etc/nanorc | grep -v "hachre/aliases" > /etc/nanorc.tmp
mv /etc/nanorc.tmp /etc/nanorc
echo "include /usr/local/hachre/aliases/nano-syntax-highlighting/*.nanorc" >> /etc/nanorc

# Install the Root Skel
if [ ! -f "/root/.zshrc_grml" ]; then
	cd /tmp
	wget -q https://raw.githubusercontent.com/hachre/aliases/master/root-skel.tar.gz
	cd /
	tar xzf /tmp/root-skel.tar.gz && rm /tmp/root-skel.tar.gz
else
	echo "Info: You already have a '/root/.zshrc-grml', so installing the Root Skel is skipped..."
fi
chown -R root:root /root
chmod u=rwX,g-rwx,o-rwx /root -R

# Switch to zsh
chsh -s `which zsh`

# Finished
echo ""
echo "Setup complete."
echo "Please run 'byobu-enable' and then log out and back in again."
echo ""

if [ "$1" != "--nozsh" ]; then
	zsh
fi