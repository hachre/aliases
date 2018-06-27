#!/bin/bash
#
# 1.0.20180627.1
#

if [ $(whoami) != "root" ]; then
	echo "Error: This setup needs to be run as root."
	exit 1
fi

# Load hachreAliases
rm -R /usr/local/hachre/aliases 1>/dev/null 2>&1
curl https://raw.githubusercontent.com/hachre/aliases/master/source/aliases.sh > /tmp/aliases.sh
source /tmp/aliases.sh && rm /tmp/aliases.sh

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
dyi "$noconfirm" git zsh mosh htop aria2 curl nano sudo wget
dyi "$noconfirm" byobu 2>/dev/null || true
rehash 2>/dev/null || true

# Install hachreAliases
wget -q -O /tmp/install.sh https://raw.githubusercontent.com/hachre/aliases/master/install.sh
bash /tmp/install.sh && rm /tmp/install.sh
source /usr/local/hachre/aliases/source/aliases.sh

# Install zsh syntax highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /usr/local/hachre/aliases/zsh-syntax-highlighting

# Install nano syntax highlighting
git clone https://github.com/scopatz/nanorc.git /usr/local/hachre/aliases/nano-syntax-highlighting
cat /etc/nanorc | grep -v "hachre/aliases" > /etc/nanorc.tmp
mv /etc/nanorc.tmp /etc/nanorc
echo "include /usr/local/hachre/aliases/nano-syntax-highlighting/*.nanorc" >> /etc/nanorc

# Installing the user defaults
if [ ! -f "$HOME/.zshrc_grml" ]; then
	# grml ZSH Settings
	wget -q -O $HOME/.zshrc_grml https://git.grml.org/f/grml-etc-core/etc/zsh/zshrc
	echo "SAVEHIST=10000" >> $HOME/.zshrc_grml

	# hachre's Default .zshrc
	cat << EOF > $HOME/.zshrc
EDITOR="nano"
source "$HOME/.zshrc_grml"
source "/usr/local/hachre/aliases/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
emulate sh -c "source /usr/local/hachre/aliases/source/aliases.sh"
if [ -f "/var/run/reboot-required" ]; then
    echo " *** Reboot required ***"
fi
echo "Welcome :)"
if [ -f "/etc/motd" ]; then
	numlines=$(cat /etc/motd | wc -l)
	if [ "$numlines" -gt "0" ]; then
		echo ""
		cat /etc/motd
	fi
fi
EOF

	# htop
	mkdir -p $HOME/.config/htop 2>/dev/null || true
	echo "hide_userland_threads=1" >> $HOME/.config/htop/htoprc
else
	echo "Warning: You already have a '$HOME/.zshrc-grml', so installing the default user settings is skipped..."
fi

# Install byobu settings
wget -q -O /tmp/byobu-settings.tar.gz https://raw.githubusercontent.com/hachre/aliases/master/byobu-settings.tar.gz
cd $HOME
tar xzf /tmp/byobu-settings.tar.gz && rm /tmp/byobu-settings.tar.gz
rm -R .byobu 2>/dev/null || true
mv byobu .byobu

# Correct home permissions
chown -R $USER $HOME/.zshrc* $HOME/.config/htop $HOME/.byobu
chmod -R u=rwX,g-rwx,o-rwx $HOME/.zshrc* $HOME/.config/htop $HOME/.byobu
chmod -R u=rwX,g-rwx,o-rwx $HOME/.ssh 2>/dev/null || true
chmod u=rwX,g-rwx,o-rwx $HOME

# Switch to zsh
chsh -s /bin/zsh

# Finished
echo ""
echo "Setup complete!"
echo "Run 'byobu-enable' and 'byobu' on your next login."