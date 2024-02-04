#!/bin/sh

wgetavail="-1"
c() {
	if [ "$wgetavail" = "-1" ]; then
		if which wget 1>/dev/null 2>&1; then
			wgetavail="1"
		else
			wgetavail="0"
		fi
	fi
	if [ "$wgetavail" = "1" ]; then
		wget "$1" -qO -
	else
		curl -kfsSL
	fi
}

set -e

# Require root to run.
if [ "$(whoami)" != "root" ]; then
	echo "Error: This setup needs to be run as root."
	exit 1
fi

# Check presence of tools we need to bootstrap dyi
checktool() {
	if ! which "$1" 1>/dev/null 2>&1; then
		echo "Please install '$1' and then run this again."
		exit 1
	fi
}
checktool wget

# If on Alpine, a lot of stuff we need will be missing. Hardcoded APK Bootstrapping
if cat /etc/*release* | grep NAME | head -n 1 | grep Alpine >/dev/null 2>&1; then
	dyDetectedDistro="alpine"
	alias dyi="apk add"
	alias dyx="apk update"
fi

cmd="$1"
# Load hachreAliases
echo "Loading hachreAliases..."
if [ "$cmd" != "--no-internet" ] && [ "$SHELL" != "/bin/sh" ]; then
	c https://raw.githubusercontent.com/hachre/aliases/master/source/aliases.sh > /tmp/aliases.sh
	. /tmp/aliases.sh || true
	# Loading hachreAliases twice in a row to switch to Nala in case it got installed
	. /tmp/aliases.sh || true
	rm /tmp/aliases.sh
fi
rm -R /usr/local/hachre/aliases 2>/dev/null || true

# Automatic installation of prequisites
installPrequisites() {
	# Set the noconfirm flag based on the distro in use
	noconfirm="-y"
	if [ "$dyDetectedDistro" = "arch" ]; then
		noconfirm="--noconfirm"
	fi

	# CentOS specific prequisities
	if [ "$dyDetectedDistro" = "CentOS" ]; then
		yum install -y epel-release || true
		yum-config-manager --enable epel 2>/dev/null || true
		dyi "$noconfirm" which
	fi

	dyinc() {
		if [ "$dyDetectedDistro" != "alpine" ]; then
			dyi "$noconfirm" "$@"
		else
			dyi "$@"
		fi
	}

	# Install the prequisites we'd like to have
	echo "Installing prequisites..."
	dyx 2>/dev/null || true
	dyinc zsh git sudo mosh nano htop aria2 bash tar wget curl
	dyinc byobu 2>/dev/null || true
	dyinc coreutils grep sed findutils less shadow util-linux-misc lsblk 2>/dev/null || true
	rehash 2>/dev/null || true
}

# Automatic prequisite installation
if [ "$cmd" != "--no-internet" ]; then
if [ "$1" = "--force" ]; then
	installPrequisites
else
	if [ "$dyDetectedDistro" != "unknown" ]; then
		installPrequisites
	else
		echo "Error: Your distribution is unknown and has not been tested for automatic package installation."
		echo "       Please install the following list of tools manually and rerun the installation with '--force':"
		echo ""
		echo "Required:    which zsh git"
		echo "Recommended: sudo mosh nano byobu"
		echo "Optional:    htop aria2 wget"
		exit 1
	fi
fi
fi

# Install Locales
if [ "$dyDetectedDistro" == "debian" ]; then
	set +e
	dyi locales
	echo -e 'LANG="en_US.UTF-8"\nLANGUAGE="en_US:en"\n' > /etc/default/locale
	locale-gen --purge en_US.UTF-8
	set -e
fi

# Install hachreAliases
echo "Installing hachreAliases..."
if [ "$cmd" != "--no-internet" ]; then
	c https://raw.githubusercontent.com/hachre/aliases/master/install.sh | bash
fi
aliases="/usr/local/hachre/aliases/source/aliases.sh"
if [ "$SHELL" = "/bin/bash" ]; then
	. "$aliases" || true
fi

# Install zsh syntax highlighting
echo "Installing zsh syntax highlighting..."
if [ "$cmd" != "--no-internet" ]; then
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /usr/local/hachre/aliases/zsh-syntax-highlighting
fi

# Install nano syntax highlighting
echo "Installing nano syntax highlighting..."
if [ "$cmd" != "--no-internet" ]; then
	git clone https://github.com/scopatz/nanorc.git /usr/local/hachre/aliases/nano-syntax-highlighting
fi
prev=$(pwd)
cd /usr/local/hachre/aliases/nano-syntax-highlighting
git checkout fe659cb3f69f7fa382aa321c8f20259c442d5d3e
cd "$prev"
if [ -f "/etc/nanorc" ]; then
	grep -v "hachre/aliases" < /etc/nanorc > /etc/nanorc.tmp
	mv /etc/nanorc.tmp /etc/nanorc
fi
echo "include /usr/local/hachre/aliases/nano-syntax-highlighting/*.nanorc" >> /etc/nanorc
if [ "$dyDetectedDistro" = "FreeBSD" ]; then
	mv /etc/nanorc /usr/local/etc/nanorc
	ln -s /usr/local/bin/bash /bin/bash
fi

# Installing the user defaults
echo "Installing default user profiles..."
if [ "$dyDetectedDistro" != "alpine" ]; then
	if [ "$cmd" != "--no-internet" ]; then
		c https://git.grml.org/f/grml-etc-core/etc/zsh/zshrc > "$HOME"/.zshrc_grml
	fi
	echo "SAVEHIST=10000" >> "$HOME"/.zshrc_grml
else
	dyinc zsh grml-zsh-config
	touch "$HOME"/.zshrc_grml
fi

# hachre's Default .zshrc
installZSHrc

# htop
mkdir -p "$HOME"/.config/htop 2>/dev/null || true
echo "hide_userland_threads=1" >> "$HOME"/.config/htop/htoprc
echo "hide_kernel_threads=1" >> "$HOME"/.config/htop/htoprc

# Install byobu settings
echo "Installing byobu settings..."
if [ "$cmd" != "--no-internet" ]; then
	c https://raw.githubusercontent.com/hachre/aliases/master/byobu-settings.tar.gz > /tmp/byobu-settings.tar.gz
fi
if [ -f "/tmp/byobu-settings.tar.gz" ]; then
	cd "$HOME"
	tar xzf /tmp/byobu-settings.tar.gz
	rm /tmp/byobu-settings.tar.gz
	rm -R .byobu 2>/dev/null || true
	mv byobu .byobu
	echo "set -g default-shell /usr/bin/zsh" > $HOME/.byobu/.tmux.conf
	echo "set -g default-command /usr/bin/zsh" >> $HOME/.byobu/.tmux.conf
else
	touch "$HOME"/.byobu
fi

# Correct home permissions
echo "Fixing some permissions in '$HOME'..."
chown -R "$USER" "$HOME"/.zshrc* "$HOME"/.config/htop "$HOME"/.byobu
chmod -R u=rwX,g-rwx,o-rwx "$HOME"/.zshrc* "$HOME"/.config/htop "$HOME"/.byobu
chmod -R u=rwX,g-rwx,o-rwx "$HOME"/.ssh 2>/dev/null || true
chmod u=rwX,g-rwx,o-rwx "$HOME"
rm "$HOME"/.bybou 1>/dev/null 2>&1 || true

# Switch to zsh
if [ ! -f "/etc/pamd./chsh" ]; then
	echo "auth sufficient pam_shells.so" > /etc/pam.d/chsh
fi
chsh -s "$(which zsh)"

# Finished
echo ""
echo "Setup complete! Relog to launch hachreShell"
