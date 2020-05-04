#!/bin/bash

# hachre's Aliases
# Author: Harald Glatt, code at hach.re
# URL: https://github.com/hachre/aliases
# Version:
hachreAliasesVersion=0.163.20200504.2

#
### hachreAliases internal stuff
#

# Welcome!
function hachreAliases() {
	echo "hachreAliases Version $hachreAliasesVersion installed and running!"
	return 0
}
alias hachre="hachreAliases"
alias hachrealiases="hachreAliases"
alias hachrealias="hachreAliases"
alias hachreAlias="hachreAliases"

# If a script needs root access, you can now call it via $hachreAliasesRoot
hachreAliasesRoot="" # deprecated
_ha_root=""
if [ `whoami` != "root" ]; then
	which sudo >/dev/null 2>&1
	if [ "$?" == "0" ]; then
		hachreAliasesRoot="sudo" # deprecated
		_ha_root="sudo"
	fi
fi

#
### Settings
#

alias eix="TERM='rxvt' eix"
alias e="$EDITOR"
alias n=e
export LANG="en_US.UTF-8"
export LC_ALL="$LANG"

#
### Aliases
#

function hachreAliasesExecuteCommand() {
	hachreAliasesCommand="$1"
	$hachreAliasesRoot $hachreAliasesSystemctl $hachreAliasesCommand
}

# zsh only aliases

if [ ! -z "$ZSH_NAME" ]; then
	# P alias to get pages
	alias -g P="| less -rEFXKn"
	# G alias to get a grep
	alias -g G="| grep -i --color"
fi

# hachre script maintenance
function hachreUpdate {
	dir="false"

	if [ -d "/usr/local/hachre/aliases" ]; then
		dir="/usr/local/hachre/aliases"
	fi

	if [ -d "$HOME/.local/hachre/aliases" ]; then
		dir="$HOME/.local/hachre/aliases"
	fi

	if [ "$dir" == "false" ]; then
		echo "Error: Your hachreAliases installation is not in the usual spot. You're on your own."
		return 1
	fi

	cur=`pwd`

	cd "$dir"
	./update.sh

	cd "$cur"

	echo "hachreAliases has been updated, please run . /etc/profile or relog to use it."
	return 0
}
alias hachreupdate="hachreUpdate"
alias hachreShellUpdate="curl -fsSL https://raw.githubusercontent.com/hachre/aliases/master/installHachreShell.sh | bash"
alias hachreshellupdate="hachreShellUpdate"

#
# Color Settings
#

alias egrep="egrep --color=always"
alias grep="grep --color=always"
alias dmesg="dmesg --color"

#
# Filesystem Helpers
#

function duhs {
	du -hsx * .* --exclude "proc" | sort -h
}

alias dfh="df -h | grep -vi docker"
alias da="du -hd 0"
alias cps="rsync -aHhP --numeric-ids --delete"
function cpss {
	if [ -z "$1" ]; then
		echo "Usage: cpss <sourcedir> <targetdir>"
		echo "Makes an exact copy of source in target using tar with gzip in the transfer."
		echo "This significantly lowers the IO load that 'cps' would create in the same process."
		echo "Resume is not supported. It is recommended to do the majority of work with 'cpss'."
		echo "And then run 'cps' with the same parameters in order to finish up."
		echo "Note: <sourcedir> needs to end on / when used with 'cps'."
		return 1
	fi
	tar cpzf - -C "$1" . | tar xpzvf - -C "$2"
}
function cpr {
	if [ -d "$1" ]; then
		echo "Error: Directories are not supported by cpr, consider cps."
	fi
	rsync --progress --append -v $*
}
alias ls="ls -F --color"
alias lsd="ls -alh"
alias l="ls -l"
alias ll="ls -l"
alias la="ls -la"
alias lad="ls -d .*(/)"
alias lh="ls -hAl"
alias lah="ls -laAh"
alias lsa="ls -a .*(.)"
alias laa="lsa -l"
alias laah="lsa -lh"
alias lsl="ls -l *(@)"
alias mdstat="cat /proc/mdstat"
function mkcd() {
	mkdir -p "$1"
	cd "$1"
}

#
# Various / Misc
#

alias ytd="youtube-dl -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/mp4' -o '%(upload_date)s - %(title)s - [%(uploader)s].%(ext)s'"
alias varnishreset="varnishadm 'ban req.url ~ .'"

function webrip() {
	if [ -z "$1" ]; then
		echo "Usage: webrip http://www.example.com"
		echo "This will rip the given website and create a tree of html files in the current directory!"
		return 1
	fi
	which wget >/dev/null 2>&1
	if [ "$?" != "0" ]; then
		echo "Webrip requires 'wget' to be installed."
		return 1
	fi
	wget -k -K  -E -r -l 10 -p -N -F --restrict-file-names=windows -nH "$1"
}

function echoerr() {
	awk " BEGIN { print \"$*\" > \"/dev/stderr\" }"
}
alias flushdns="sudo discoveryutil mdnsflushcache;sudo discoveryutil udnsflushcaches;dscacheutil -flushcache"
function psall() {
	if [ -z "$1" ]; then
		ps aux | grep -v '\[' | grep -v '\]'
	else
		ps aux | grep -v '\[' | grep -v '\]' | grep -i "$1" | grep -v "grep"
	fi
}
alias lsnet="ls /sys/class/net"
alias checkheaders="curl -I"
function checkssl {
	if [ -z "$1" ]; then
		echo "Usage: checkssl <hostname>"
		return 1
	fi
	#openssl s_client -servername $1 -connect $1:443 -showcerts -nextprotoneg '' </dev/null
	openssl s_client -servername $1 -connect $1:443 < /dev/null
}
alias lp="nice -n 18 ionice -c idle"
alias hp="nice -n -15 ionice -c best-effort"
function findip() {
	if [ -z "$1" ]; then
		echo "Usage: findip <hostname>"
		return 1
	fi
	dig +short $(dig mx +short $1)
}
alias debugchrome="open -a /Applications/Google\ Chrome\ Canary.app --args --disable-web-security --ignore-certificate-errors --user-data-dir /dev/null"
function eixupdate {
	if [ ! -f "/etc/eix-sync.conf" ]; then
		echo "*" > /etc/eix-sync.conf
	fi
	eix-remote update
	eix-update
	echo "EIX is ready to go! Use -R to search in layman..."
}
function kernelVersion {
	if [ "$dyDetectedDistro" == "sabayon" ]; then
		equo query installed -v "linux-sabayon" | grep -i version | awk '{ print $4 }'
		return 0
	fi

	uname -r
}
function kernelUpdate {
	if [ "$dyDetectedDistro" == "sabayon" ]; then
		#kernel-switcher list
		dys linux-sabayon

		version="null"
		largerthan=""

		if [ -z "$1" ]; then
			echo ""
			echo "Usage: kernelUpdate (target version) [ex: 3.19.1]"
			echo " -> If no parameter is specified a higher-than-current version is assumed."
			echo ""
		else
			version="$1"
		fi

		if [ "$version" == "null" ]; then
			version=`kernelVersion`
			largerthan=">"
		fi

		kernel-switcher switch -av ${largerthan}sys-kernel/linux-sabayon-${version}
		return 0
	fi

	echo "Error: kernelUpdate is not implemented for your platform."
	return 1
}
function checkio {
	which iostat >/dev/null 2>&1
	if [ "$?" != "0" ]; then
		echo "checkio needs iostat installed (sysstat package)"
		return 1
	fi
	iostat -dkxz 1
}
alias aria2c="aria2c -x 10 -j 10 --file-allocation=falloc"

function installCode {
	echo "Installing basic code environment... Wait for the 'All done' message!"
	dyi git git-lfs nodejs npm jre rsync imagemagick ghostscript &&
	npm install -g typescript &&
	npm install -g metalsmith &&
	npm install -g browserify &&
	npm install -g closurecompiler &&
	cd &&
	git lfs install &&
	rm -Rf lfs &&
	git config --global user.name 'Harald Glatt' &&
	git config --global user.email 'code@hach.re' &&
	git config --global core.fileMode false &&
	echo "All done :)"
}

#
# Btrfs
#

function btrfsDefragMeta {
	if [ -z "$1" ]; then
		echo "Usage: btrfsDefragMeta <volume mountpoint>"
		return 1
	fi

	if [ ! -d "$1" ]; then
		echo "Error: Given parameter is not a mount point."
		return 1
	fi

	btrfs fi defrag -v "$1"
	find "$1" -xdev -type d -exec btrfs fi defrag -v {} \;
}

function btrfsDefragData {
	if [ -z "$1" ]; then
		echo "Usage: btrfsDefragData <volume mountpoint>"
		return 1
	fi

	if [ ! -d "$1" ]; then
		echo "Error: Given parameter is not a mount point."
		return 1
	fi

	btrfs fi defrag -r -v -clzo "$1"
}

function btrfsMaint {
	if [ -z "$1" ]; then
		echo "Usage: btrfsMaint [volume mountpoint] (dusage/musage parameter)"
		echo "Defrags metadata & data, deduplicates and runs a maintenance balance."
		return 1
	fi

	dyTmpUsage="10"
	if [ ! -z "$2" ]; then
		dyTmpUsage="$2"
	fi

	if [ ! -d "$1" ]; then
		echo "Error: Given parameter is not a mount point."
		return 1
	fi

	if [ -f "/tmp/btrfsMaintenance" ]; then
		lastdate=`cat /tmp/btrfsMaintenance`
		if [ -z "$lastdate" ]; then
			lastdate="null"
		fi
	fi

	curdate=`date +%Y%m%d`
	if [ "$lastdate" != "$curdate" ]; then
		btrfsDefragMeta "$1"
		btrfsDefragData "$1"
		which bedup >/dev/null 2>&1
		if [ "$?" == "0" ]; then
			bedup dedup --defrag --size-cutoff 262144
		else
			echo "Skipped: bedup (deduplication) skipped because bedup is not installed..."
		fi
		echo "$curdate" > /tmp/btrfsMaintenance
	else
		echo "Info: Skipping btrfsDefrag and dedup steps because they already ran today."
		echo "If you really need them again, delete '/tmp/btrfsMaintenance'"
		echo ""
	fi

	echo "Running balance with usage: '$dyTmpsage'."
	echo " * If you want you can rerun the command with higher usage values."
	echo " * Be careful because an increase in the usage value can lead"
	echo "   to very long execution times."
	echo ""
	btrfs fi bal start -dusage="$dyTmpUsage" -musage="$dyTmpUsage" -v "$1"

	echo ""
	echo "All done, you can choose to schedule a scrub as well, using btrfsScrub."
}

function btrfsScrub {
	if [ -z "$1" ]; then
		echo "Usage: btrfsScrub [volume mountpoint]"
		return 1
	fi

	if [ ! -d "$1" ]; then
		echo "Error: Given parameter is not a mount point."
		return 1
	fi

	btrfs scrub start -B "$1"
}

function logout {
	sh -c "killall mosh-server; kill $(pidof tmux)"
}

#
# SSH
#

alias scpi='scp -o "StrictHostKeyChecking=no" -o "UserKnownHostsFile=/dev/null"'
alias sshi='ssh -o "StrictHostKeyChecking=no" -o "UserKnownHostsFile=/dev/null"'

#
# Editors
#

alias nano="nano -w -T 4"
alias sublime="subl"
alias sub="subl"

#
# GIT
#

alias gits="git status"
alias gitl="git log"
alias gitrev="git rev-list --all | wc -l"
alias gitedit="echo 'Usage: gitedit HEAD~N'; git rebase --interactive"
alias gitlookup="echo 'Usage: gitlookup id'; git rev-list --objects --all | grep"
alias gitlargest="git verify-pack -v .git/objects/pack/pack-*.idx | sort -k 3 -n | tail -5"
alias gitdiff="git diff HEAD~1 HEAD"
alias gitlog="git log"
function gitbranch() {
	if [ -z "$1" ]; then
		echo "Usage: gitbranch <branchname>"
		return 1
	fi
	git checkout -b $1
	git push -u origin $1
}
function gitmerge() {
	if [ -z "$1" ]; then
		echo "Usage: gitmerge <branchname>"
		return 1
	fi
	git checkout master
	git merge $1
	echo "Use gitbranchrm <branchname> to delete the useless branch now."
}
function gitbranchrm() {
	if [ -z "$1" ]; then
		echo "Usage: gitbranchrm <branchname>"
		return 1
	fi
	git checkout master
	git push
	git branch -d $1
	git push
	git push --delete origin $1
}
function gitit() {
	commit="dev"
	if [ -e "version.txt" ]; then
		$EDITOR "version.txt"
		commit=`cat version.txt | head -n 1`
	fi

	git add .
	git add -A *
	git add .gitignore
	git commit -a -e -m "$commit"
}
function gitrmCleanup() {
	git gc
	rm -Rf .git/refs/original
	git reflog expire --all --expire='0 days'
	git fsck --full --unreachable
	git repack -A -d
	git prune
}
function gitrmDelete() {
	git filter-branch -f --force --index-filter "git rm -r --cached --ignore-unmatch '$1'" --prune-empty --tag-name-filter cat -- --all
	if [ "$?" != "0" ]; then
		return $?
	fi

	gitrmCleanup
	gitrmCleanup
}
function gitrm() {
	if [ -z "$1" ] || [ "$1" == "--help" ]; then
		echo "Usage: gitrm <filename / directory> [--force]"
		return 1
	fi

	if [ "$2" != "--force" ]; then
		if [ ! -e "$1" ]; then
			echo "Error: Given file / directory doesn't exist: '$1', you can use --force."
			return 1
		fi
	fi

	gitrmDelete "$1"
}
function gitreset() {
	git fetch --all
	git reset --hard origin/master
}
function gitresetauthor() {
	git filter-branch --commit-filter 'export GIT_AUTHOR_NAME="Harald Glatt"; export GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME" ; export GIT_AUTHOR_EMAIL=code@hach.re; export GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL" ;git commit-tree "$@"' -f
}

# OpenSUSE OpenSuse Zypper Defaults
alias zypper="zypper --color -s 7"
alias zypunneeded="zyp -q packages --unneeded | cut -d │ -f 3 | sort | uniq | grep -v ══ | grep -vw Name"
alias zyporphaned="zyp -q packages --orphaned | cut -d │ -f 3 | sort | uniq | grep -v ══ | grep -vw Name"

#
# Ubuntu / Debian Package Management
#

# deprecated
which apt >/dev/null 2>&1
if [ "$?" == "0" ]; then
	alias aga="sudo apt autoremove"
	alias agar="sudo apt autoremove"
	alias agr="sudo apt remove"
	alias agi="sudo apt install"
	alias au="sudo apt update"
	alias adg="sudo apt full-upgrade"
	alias ama="sudo apt-mark auto"
	alias amh="sudo apt-mark hold"
	alias amm="sudo apt-mark hold"
	alias amsm="apt-mark showmanual"
	alias amsa="apt-mark showauto"
	alias amsh="apt-mark showhold"
fi

#
# Arch Package Management
#

function setupArchAliases() {
	alias pmie="$root $hachreAliasesArchPM -Suy --asexplicit"
	alias pmid="$root $hachreAliasesArchPM -Suy --asdeps"
	alias pmqq="$root $hachreAliasesArchPM -Qq"
	alias pmqi="$root $hachreAliasesArchPM -Qi"
	alias pmqe="$root $hachreAliasesArchPM -Q --explicit"
	alias pmqd="$root $hachreAliasesArchPM -Q --deps"
	alias pmql="$root $hachreAliasesArchPM -Ql"
	alias pmqm="$root $hachreAliasesArchPM -Qm"
	alias pmme="$root $hachreAliasesArchPM -D --asexplicit"
	alias pmmd="$root $hachreAliasesArchPM -D --asdeps"
	alias pmse="pmme"
	alias pmsd="pmmd"
	function pmrf() {
		$root $hachreAliasesArchPM -Rcs $(pacman -Qqs "$@")
	}
	alias pmlast="$hachreAliasesRoot paclog-pkglist /var/log/pacman.log | cut -d ' ' -f 1"
	function dyconf() {
		echoerr "This is a list of modified config files:"
		$_ha_arch_pm -Qii | awk '/^MODIFIED/ {print $2}'
	}
	function _ha_arch_aur() {
		d=${BUILDDIR:-$PWD}
		for p in ${@##-*}; do
			cd $d
			$_ha_root curl https://aur.archlinux.org/cgit/aur.git/snapshot/$p.tar.gz | $_ha_root tar xz
			cd $p
			if [ -d "$d/proc" ]; then
				echo "Error: '$d' ended up being root. This isn't normal. Exiting..."
				return 1
			fi
			$_ha_root chown archbuild "$d" -R
			$_ha_arch_build makepkg -si --needed --noconfirm --skippgpcheck ${@##[^\-]*}
		done
	}
	function dySetup() {
		if [[ "$0" != *zsh* ]]; then
			echo "Error: dySetup must be run from within a zsh shell."
			return 1
		fi

		if [ $(whoami) != "root" ]; then
			echo "Error: dySetup must be run as root."
			return 1
		fi

		echo "Proceeding to set up the legendary hachre Arch Build System... (CTRL+C within 3 sec to abort)"
		if [ "$1" != "--nosleep" ]; then
			sleep 3
		fi

		setopt local_options err_return

		user="archbuild"
		echo "Setting up $user user..."
		_ha_arch_build="sudo -u $user"

		$_ha_root userdel -rf "$user" 1>/dev/null 2>&1 || true
		$_ha_root rm -R /home/"$user" 1>/dev/null 2>&1 || true
		$_ha_root groupdel -f "$user" 1>/dev/null 2>&1 || true
		$_ha_root groupadd -g 500 archbuild
		$_ha_root useradd -u 500 -g 500 -m "$user"
		$_ha_root chown "$user" /home/"$user" -R
		$_ha_root rm -R /home/"$user"/.gnupg 1>/dev/null 2>&1 || true
		$_ha_arch_build mkdir /home/"$user"/.gnupg
		$_ha_arch_build chmod 770 /home/"$user"/.gnupg -R
		echo "keyring /etc/pacman.d/gnupg/pubring.gpg" | $_ha_arch_build tee -a /home/"$user"/.gnupg/gpg.conf
		sync
		$_ha_arch_build gpg --list-keys 1>/dev/null

		echo "Installing required prequisite packages..."
		$_ha_root pacman --color always -S --needed --noconfirm sudo curl wget binutils base-devel git || true
		$_ha_root pacman --color always -R --noconfirm pacaur 2>/dev/null || true
		$_ha_root pacman --color always -R --noconfirm cower 2>/dev/null || true
		$_ha_root pacman --color always -R --noconfirm yay 2>/dev/null || true

		$_ha_root cat /etc/sudoers | grep -v hachreLine | $_ha_root tee -a /etc/sudoers.tmp 1>/dev/null
		$_ha_root mv /etc/sudoers.tmp /etc/sudoers
		$_ha_root chmod 600 /etc/sudoers
		echo "$user ALL=(ALL) NOPASSWD: $(which pacman) # hachreLine" | $_ha_root tee -a /etc/sudoers 1>/dev/null
		echo "Defaults env_keep += \"EDITOR\" # hachreLine" | $_ha_root tee -a /etc/sudoers 1>/dev/null

		echo "Building and installing Yay..."
		pwd=$(pwd)
		mytemp=$($_ha_root mktemp)
		$_ha_root rm "$mytemp"
		$_ha_root mkdir -p "$mytemp"
		$_ha_root chown -R archbuild "$mytemp"
		cd "$mytemp"
		_ha_arch_aur yay
		$_ha_root rm -Rf "$mytemp"
		cd "$pwd"

		echo "%$user ALL=(ALL) NOPASSWD: $(which yay), $(which pacman) # hachreLine" | $_ha_root tee -a /etc/sudoers 1>/dev/null

		echo "Amending Pacman configuration..."
		$_ha_root sed -i 's|#Color|Color|' /etc/pacman.conf

		# Put current user into the archbuild group
		$_ha_root usermod -G archbuild -a $USER 1>/dev/null 2>&1 || true

		echo "The set up of the legendary hachre Arch Build System was completed successfully."
		echo " -> If you use a non-root user to do package management, add them to the 'archbuild' group."
		echo "    Example: 'sudo usermod -G archbuild -a $USER'"
	}
	alias pmSetup="dySetup"

	function __hachreAliasesCleanLogs() {
		echo "Cleaning all logs, you can CTRL+C within 10 seconds..."
		echo ""
		echo " -> We will empty all files in the first pass and then if"
		echo "    you run this again we will delete the 0 size files."
		echo " -> This means you are expected to reboot and let some time"
		echo "    pass between two clean calls."
		echo ""
		sleep 10
		cd /var/log
		for entry in `/bin/ls /var/log`; do
			if [ -f "$entry" ]; then
				if [ ! -s "$entry" ]; then
					if [ "$entry" == "pacman.log" ]; then
						continue
					fi
					if [ "$entry" == "emerge.log" ]; then
						continue
					fi
					if [ "$entry" == "emerge-fetch.log" ]; then
						continue
					fi

					echo "Emptying file: '$entry'"
					echo "" > "$entry"
					continue
				fi
				echo "Removing file: '$entry'"
				rm "$entry" >/dev/null 2>&1
				continue
			fi
			if [ -d "$entry" ]; then
				if [ "$entry" == "portage" ]; then
					continue
				fi

				echo "Emptying dir: '$entry'"
				/bin/rm -Rf "$entry"/* >/dev/null 2>&1
				continue
			fi
			echo "Unknown: '$entry'"
			echo " -> didn't do anything with this"
		done
	}
	alias __logclean="hachreAliasesCleanLogs"
	alias __baseclean="echo 'Baseclean cleans a lot of stuff... You may CTRL+C!'; $root $hachreAliasesArchPM -Scc && sudo rm -Rf /var/cache/pkgfile/* >/dev/null 2>&1 && sudo rm -Rf /var/abs/* >/dev/null 2>&1 && sudo rm -Rf /var/cache/lxc/* >/dev/null 2>&1 && hachreAliasesCleanLogs"
}

#
# hachreProjects
#
function packageProjects() {
	# package hachreProjects (tm)

	# Configuration
	destdir="/Volumes/Solaris/Sync/Backups/Code/Backups"
	#destdir2="$HOME/MEGA/Backups/Code/Backups"

	# We assume to be in a project root directory.
	# Traverse subfolders and search for version.txt files.
	for project in `find * -maxdepth 0 -type d -print`; do
		echo ""
		echo "* $project"

		version=`cat ./$project/version.txt 2>/dev/null`
		if [ "$?" != "0" ]; then
			version="invalid"
		fi

		if [ "$version" == "invalid" ]; then
			echo "  -> Invalid project, skipping..."
			continue
		fi

		echo "  -> Current Version: $version"

		name="${project}_${version}"

		#echo "${destdir}/${name}.tar.xz"
		if [ -f "${destdir}/${name}.tar.xz" ]; then
			echo "  -> Current backup for package already exists, skipping..."
			continue
		fi

		echo "  -> Creating package: $name.tar.xz"

		tar cf "$name.tar" "./$project"
		xz -v "$name.tar"
		rm "$name.tar" >/dev/null 2>&1

		echo "  -> Package created."
	done

	echo "Moving created packages into Archive..."
	mv *xz "$destdir" > /dev/null 2>&1
	if [ ! -z "$destdir2" ]; then
		rsync -aHhP --numeric-ids --delete "$destdir"/* "$destdir2/"
	fi
}

#
# $dyDetectedDistro below this point
#

dyDetectedDistro="null"
function dyDetectDistro {
	if [ "$dyDetectedDistro" != "null" ]; then
		return 0
	fi

	# Sabayon
	which -p equo 1>/dev/null 2>/dev/null
	if [ "$?" == "0" ]; then
		dyDetectedDistro="sabayon"
		dyDistroInfo="\n * The native package manager for this distro is called 'equo'.\n * You might also need to use 'emerge' in advanced circumstances.\n * Searching is best done via 'eix'."
		function remerge {
			/usr/bin/emerge $@
		}
		function emerge {
			echo "Warning: 'emerge' should not be used on Sabayon, unless you know what you are doing!!!"
			echo ""
			echo "Some pointers:"
			echo " 1. You are not allowed to do anything involving 'world' or 'system' etc."
			echo " 2. Any dependencies should be installed with"
			echo "    $ equo install --bdeps --onlydeps <package>"
			echo "    instead of emerge."
			echo " 3. It is generally recommended to use 'dyii' instead."
			echo ""
			echo "If you really need 'emerge', run the command again now..."
			unset -f emerge
			return 1
		}
		return 0
	fi

	# Gentoo
	which -p emerge 1>/dev/null 2>&1
	if [ "$?" == "0" ]; then
		dyDetectedDistro="gentoo"
		dyDistroName="Gentoo Linux"
		dyDistroInfo="\n * The native package manager for this distro is called 'emerge'.\n * You might also wanna look at 'equery'\n * Searching is best done via 'eix'."
		return 0
	fi

	# Arch
	which -p pacman 1>/dev/null 2>&1
	if [ "$?" == "0" ]; then
		dyDetectedDistro="arch"
		dyDistroName="Arch Linux"
		dyDistroInfo="\n * The native package manager for this distro is called 'pacman'.\n * You might also wanna look at 'yay'."

		# Manjaro
		cat /etc/*release* | grep "Manjaro" 1>/dev/null 2>&1
		if [ "$?" == "0" ]; then
			dyDistroName="Manjaro Linux"
		fi

		# Netrunner
		cat /etc/*release* | grep "Netrunner" 1>/dev/null 2>&1
		if [ "$?" == "0" ]; then
			dyDistroName="Netrunner OS"
		fi

		return 0
	fi

	# OS X with Brew
	if [ -f "/usr/local/bin/brew" ]; then
		dyDetectedDistro="osx-brew"
		dyDistroName"macOS with brew"
		dyDistroInfo="\n * The native package manager is 'brew'."
		return 0
	fi

	# Windows
	which apt-get 1>/dev/null 2>&1
	if [ "$?" == "0" ]; then
		if [ -f "/mnt/c/Windows/explorer.exe" ]; then
			dyDetectedDistro="windows"
			dyDistroName="Ubuntu on Windows"
			dyDistroInfo="\n * The native package manager for this distro is called 'apt' and 'apt-get'."
			return 0
		fi
	fi

	# FreeBSD
	which freebsd-version 1>/dev/null 2>&1
	if [ "$?" == "0" ]; then
		dyDetectedDistro="FreeBSD"
		dyDistroName="FreeBSD"
		dyDistroInfo="\n * The native package manager for this distro is called 'pkg'.\n * The alternate package manager is called ports and runs through '$dyAltPkgManager'\n * To search inside of ports use 'psearch'\n * To install new major versions you should use 'freebsd-update fetch install'."
		return 0
	fi

	# Ubuntu
	which lsb_release 1>/dev/null 2>&1
	if [ "$?" == "0" ]; then
		release=$(lsb_release -is)
		if [ "$release" == "Ubuntu" ]; then
			dyDetectedDistro="ubuntu"
			dyDistroName="Ubuntu Linux"
			dyDistroInfo="\n * The native package manager for this distro is called 'apt' and 'apt-get'. You might also want to look at 'apt-cache', 'dpkg' and 'aptitude'"
			return 0
		fi
		if [ "$release" == "Debian" ]; then
			dyDetectedDistro="ubuntu"
			dyDistroName="Debian"
			dyDistroInfo="\n * The native package manager for this distro is called 'apt' and 'apt-get'. You might also want to look at 'apt-cache', 'dpkg' and 'aptitude'"
			return 0
		fi
	fi

	# Alpine Linux
	cat /etc/alpine-release 1>/dev/null 2>/dev/null
	if [ "$?" == "0" ]; then
		ls /sbin/apk 1>/dev/null 2>&1
		if [ "$?" == "0" ]; then
			dyDetectedDistro="alpine"
			dyDistroName="Alpine"
			dyDistroInfo="\n * The native package manager for this distro is called 'apk'. It has coffee making abilities."
			return 0
		fi
	fi

	# CentOS, OracleLinux
	# TODO: switch all uses of which to command -v
	command -v yum 1>/dev/null 2>&1
	if [ "$?" == "0" ]; then
		dyDetectedDistro="CentOS"
		dyDistroName="$dyDetectedDistro"
		dyDistroInfo="\n * Using command aliases for distro '$dyDetectedDistro'.\n * The native package manager for this distro is called 'yum'."
		if [ -f "/etc/os-release" ]; then
			source /etc/os-release
			dyDistroName="$NAME"
			NAME=""
			export NAME=""
		fi
		return 0
	fi

	# OpenSUSE (needs to be last because of which -p)
	which -p zypper 1>/dev/null 2>&1
	if [ "$?" == "0" ]; then
		dyDetectedDistro="opensuse"
		dyDistroName="OpenSUSE"
		dyDistroInfo="\n * The native package manager for this distro is called 'zypper'."
		return 0
	fi

	# Not found
	dyDetectedDistro="unknown"
	return 1
}
dyDetectDistro

# Set up Arch aliases
if [ "$dyDetectedDistro" == "arch" ]; then
	which pacman >/dev/null 2>&1
	if [ "$?" == "0" ]; then
		hachreAliasesArchPM="pacman --color always" # deprecated
		_ha_arch_pm="$_ha_root pacman --color always"

		# Pacaur is deprecated
		which pacaur >/dev/null 2>&1
		if [ "$?" == "0" ]; then
			root="sudo -u archbuild -s" # deprecated
			hachreAliasesArchPM="pacaur --noedit --color always" # deprecated
		fi

		which yay >/dev/null 2>&1
		if [ "$?" == "0" ]; then
			_ha_arch_build="sudo -u archbuild"
			_ha_arch_pm="$_ha_arch_build yay --nodiffmenu --nocleanmenu --answeredit N"
		fi

		setupArchAliases
	fi
fi

usednf="unchecked"
function dyYumCmd {
	if [ "$usednf" == "unchecked" ]; then
		which dnf 1>/dev/null 2>&1
		if [ "$?" == "0" ]; then
			usednf="1"
		else
			usednf="0"
 		fi
	fi
	if [ "$usednf" == "1" ]; then
		echo "dnf"
		return 0
	fi
	if [ "$usednf" == "0" ]; then
		echo "yum"
	fi
}

# helper functions
function dyFreeBSDResolvePortPathOld {
	pwd="$PWD"
	cd /usr/ports
	echo `make search name="$*" display=path | head -n 1 | awk '{print $2}'`
	cd "$pwd"
}
function dyFreeBSDResolvePortPath {
	echo /usr/ports/*/$1
}

function dyFreeBSDCheckPortsUtilsOld {
	if [ "$dyDetectedDistro" != "FreeBSD" ]; then
		return 0
	fi

	which portmaster 1>/dev/null 2>&1
	if [ "$?" != "0" ]; then
		# Use traditional installation method to install portmaster
		pwd="$PWD"
		cd /usr/ports
		path=`dyFreeBSDResolvePortPathOld portmaster`
		if [ ! -d "path" ]; then
			echo "Error: Couldn't install portmaster."
			return 1
		fi
		cd "$path"
		$hachreAliasesRoot make install clean
		cd "$pwd"
	fi

	which psearch 1>/dev/null 2>&1
	if [ "$?" != "0" ]; then
		# Install psearch via just installed portmaster
		path=`dyFreeBSDResolvePortPathOld psearch`
		$hachreAliasesRoot portmaster "$path"
	fi
}

function dyFreeBSDCheckPortsUtils {
	if [ "$dyDetectedDistro" != "FreeBSD" ]; then
		return 0
	fi

	which portsnap 1>/dev/null 2>&1
	if [ "$?" != "0" ]; then
		dyi -y portsnap
	fi

	if [ ! -f "/usr/ports/CHANGES" ]; then
		portsnap fetch extract
	fi

	if [ ! -d "/usr/ports/distfiles" ]; then
		mkdir /usr/ports/distfiles
	fi

	which psearch 1>/dev/null 2>&1
	if [ "$?" != "0" ]; then
		dyi -y psearch
	fi

	which synth 1>/dev/null 2>&1
	if [ "$?" != "0" ]; then
		dyi -y synth
		synth configure
		echo "Run 'synth configure' to configure synth some more."
	fi
}

#
# hachre's unified packaging commands
#
dyAltPkgManager=""
if [ "$dyDetectedDistro" == "FreeBSD" ]; then
	dyAltPkgManager="synth"
fi
function dyh {
	if [ "$dyDetectedDistro" == "unknown" ]; then
		echo "Error: Sadly, your distro is not supported."
		return 1
	fi

	echo "dynaloop unified package managing commands"
	echo ""

	displayDistro="$dyDetectedDistro"
	if [ ! -z "$dyDistroName" ]; then
		displayDistro="$dyDistroName"
	fi

	echo "Your distro is supported and has been detected as '$displayDistro'."
	if [ ! -z "${dyDistroInfo}" ]; then
		echo -e "${dyDistroInfo}"
	fi

    if [ "$1" == "-v" ]; then
        echo ""
        echo "List of unified package management commands:"
        echo -e " dyi\tInstall a package from the primary repo (after confirmation)"
        echo -e " dyif\tInstall a package forced from the primary repo (after confirmation)"
        echo -e " dyii\tInstall a package from the secondary repo (after confirmation)"
        echo -e " dyr\tRemove a package (after confirmation, including its unused dependencies)"
        echo -e " dyrf\tRemove a package forced (after confirmation, including its unused dependencies)"
        echo -e " dyu\tDo a full system upgrade after Syncing (primary repo)"
        echo -e " dyus\tInstall security updates only (not widely supported)"
        echo -e " dyuu\tDo a full system upgrade (secondary repo)"
		echo -e " dyq\tQuery detailed package information"
		echo -e " dyo\tFind which package owns given file"
		echo -e " dyl\tList files owned by given package"
        echo -e " dyk\tUpdate verification signing keys"
        echo -e " dyv\tVerify system sanity"
        echo -e " dyw\tShow all manually selected packages (world)"
        echo -e " dyx\tSync the primary repository"
        echo -e " dyxx\tSync the secondary repository"
        echo -e " dys\tSearch a package (in the main repo)"
        echo -e " dyss\tSearch a package (in the extended repo)"
    else
        echo ""
        echo "How to search:"
        echo -e "\tdys <searchterm>"

        echo ""
        echo "How to install a specific package:"
        echo -e "\tdyi <packagename>"

        echo ""
        echo "How to remove a specific package:"
        echo -e "\tdyr <packagename>"

        echo ""
        echo "How to install the latest security updates:"
        echo -e "\tdyus"

        echo ""
        echo "How to fully update your system:"
        echo -e "\tdyu"

        echo ""
        echo "If you need more commands, use 'dyh -v'"
    fi

	if [ "$dyDetectedDistro" == "CentOS" ]; then
		echo -e "\nAs a user of CentOS features, you also have access to 'dyundo' which allows\nto rollback previous package manager actions. Check 'dyundo --help'."
	fi

	return 0
}

function dyc {
	if [ -z "$1" ]; then
		echo "Usage: dyc <package name>"
		echo "Configures the package for later installation with dyii"
		echo "Also check: dyc, dycc (recursive), dycr (remove single), dyccr (remove, recursive)"
		return 1
	fi
	if [ "$dyDetectedDistro" == "FreeBSD" ]; then
		make -C $(dyFreeBSDResolvePortPath $1) config
		echo "All done :) Now you can install with dyii <package name>"
		return $?
	fi

	echo "This command is not supported on your platform."
}

function dycc {
	if [ -z "$1" ]; then
		echo "Usage: dycc <package name>"
		echo "Configures the package and its dependencies for later installation with dyii"
		echo "Also check: dyc, dycc (recursive), dycr (remove single), dyccr (remove, recursive)"
		return 1
	fi
	if [ "$dyDetectedDistro" == "FreeBSD" ]; then
		make -C $(dyFreeBSDResolvePortPath $1) config-recursive
		echo "All done :) Now you can install with dyii <package name>"
		return $?
	fi

	echo "This command is not supported on your platform."
}

function dycr {
	if [ -z "$1" ]; then
		echo "Usage: dycr <package name>"
		echo "Removes the package configuration and resets it to defaults"
		echo "Also check: dyc, dycc (recursive), dycr (remove single), dyccr (remove, recursive)"
		return 1
	fi
	if [ "$dyDetectedDistro" == "FreeBSD" ]; then
		make -C $(dyFreeBSDResolvePortPath $1) rmconfig
		echo "All done :)"
		return $?
	fi

	echo "This command is not supported on your platform."
}

function dyccr {
	if [ -z "$1" ]; then
		echo "Usage: dyccr <package name>"
		echo "Removes the package configuration recursively and resets it to defaults"
		echo "Also check: dyc, dycc (recursive), dycr (remove single), dyccr (remove, recursive)"
		return 1
	fi
	if [ "$dyDetectedDistro" == "FreeBSD" ]; then
		make -C $(dyFreeBSDResolvePortPath $1) rmconfig-recursive
		echo "All done :)"
		return $?
	fi

	echo "This command is not supported on your platform."
}

function dyk {
	if [ "$dyDetectedDistro" == "arch" ]; then
        function printinfo {
            echo ""
            echo "If there are still GPG problems, try running 'dyk --reset' and/or run dySetup."
        }

        if [ -z "$1" ]; then
            echo "Updating all keys. To update a specific key use 'dyk <keyid>'"
            $hachreAliasesRoot pacman-key --refresh-keys
			echo "Refresh done."
            printinfo
    		return $?
        fi
        if [ "$1" == "--reset" ]; then
            echo "Resetting key system..."
            $hachreAliasesRoot pacman-key --init
            $hachreAliasesRoot pacman-key --populate
            $hachreAliasesRoot pacman-key --refresh-keys
			echo "Full key reset done."
            printinfo
    		return $?
        fi
        echo "Updating specific key..."
        $hachreAliasesRoot pacman-key -r $@
        printinfo
        return $?
	fi

	echo "This command is not supported on your platform."
}

# This is CentOS (yum) only
function dyundo {
	if [ "$dyDetectedDistro" != "CentOS" ]; then
		return 1
	fi

	if [ -z "$1" ] || [ "$1" == "--help" ]; then
		echo -e "Usage: dyundo <command> [command parameter]\n"
		echo -e " Note: You can also use 'yum history' directly.\n"
		echo " Possible commands are:"
		#echo "  --stats:        display various historic stats"
		echo "  --history:      display a list of previous transactions"
		echo "  --undo <N>:     undo the single transaction with id N"
		echo "  --rollback <N>: rollback everything up until transaction with id N"
		return 1
	fi

	#if [ "$1" == "--stats" ]; then
	#	$hachreAliasesRoot $(dyYumCmd) history stats
	#	return $?
	#fi

	if [ "$1" == "--history" ]; then
		$hachreAliasesRoot $(dyYumCmd) history
		return $?
	fi

	if [ "$1" == "--undo" ]; then
		$hachreAliasesRoot $(dyYumCmd) history undo "$2"
		return $?
	fi

	if [ "$1" == "--rollback" ]; then
		$hachreAliasesRoot $(dyYumCmd) history rollback "$2"
		return $?
	fi

	echo "Given command '$1' not understood. Check '--help'."
	return 1
}

function dyq {
	if [ "$dyDetectedDistro" == "arch" ]; then
		$_ha_arch_pm -Si $@
		return $?
	fi

	if [ "$dyDetectedDistro" == "CentOS" ]; then
		$hachreAliasesRoot $(dyYumCmd) info $@ | tee
		return $?
	fi

	if [ "$dyDetectedDistro" == "FreeBSD" ]; then
		$hachreAliasesRoot pkg info $@ P
		return $?
	fi

	if [ "$dyDetectedDistro" == "ubuntu" ]; then
		apt show $@
		return $?
	fi

	if [ "$dyDetectedDistro" == "alpine" ]; then
		apk info -L $*
		apk info $*
		apk info -e $* 1>/dev/null 2>&1
 		if [ "$?" == "0" ]; then
			echo "$1 is installed."
		else
			echo "$1 is not installed."
		fi
		return 0
	fi
	echo "This command is not supported on your platform."
}

function dyx {
	if [ "$dyDetectedDistro" == "sabayon" ]; then
		equo update
		return $?
	fi

	if [ "$dyDetectedDistro" == "gentoo" ]; then
		echo "Syncing..."
		which emerge-webrsync >/dev/null 2>&1
		if [ "$?" == "0" ]; then
			emerge-webrsync
		fi
		emerge --sync

		eix-update >/dev/null 2>&1 &
		echo ""
		echo "Syncing is done, but the searcher database is still syncing in the background... (psall eix)"
		return $?
	fi

	if [ "$dyDetectedDistro" == "osx-brew" ]; then
		brew update
		return $?
	fi

	if [ "$dyDetectedDistro" == "arch" ]; then
    	$_ha_arch_pm -Sy
		return $?
	fi

	if [ "$dyDetectedDistro" == "alpine" ]; then
		apk update
		return $?
	fi

  if [ "$dyDetectedDistro" == "opensuse" ]; then
    $hachreAliasesRoot zypper ref -s
		return $?
	fi

  if [ "$dyDetectedDistro" == "windows" ] || [ "$dyDetectedDistro" == "ubuntu" ]; then
    $hachreAliasesRoot apt update
		return $?
	fi

	if [ "$dyDetectedDistro" == "FreeBSD" ]; then
    $hachreAliasesRoot pkg update
		return $?
	fi

	echo "This command is not supported on your platform."
}

function dyxx {
	if [ "$dyDetectedDistro" == "sabayon" ]; then
		echo "Syncing..."
		which emerge-webrsync >/dev/null 2>&1
		if [ "$?" == "0" ]; then
			emerge-webrsync
		fi
		/usr/bin/emerge --sync

		layman -D sabayon >/dev/null 2>&1
		if [ "$?" != "0" ]; then
			echo " ------- Answer y in the following dialog!!!"
			layman -a sabayon
		fi
		layman -E sabayon >/dev/null 2>&1
		layman -D sabayon-distro >/dev/null 2>&1
		if [ "$?" != "0" ]; then
			echo " ------- Answer y in the following dialog!!!"
			layman -a sabayon-distro
		fi
		layman -E sabayon-distro >/dev/null 2>&1
		layman -S

		eix-remote update >/dev/null 2>&1 &
		echo ""
		echo "Syncing is done, but the searcher database is still syncing in the background... (psall eix)"
		return $?
	fi

	if [ "$dyDetectedDistro" == "gentoo" ]; then
		layman -S

		eix-remote update >/dev/null 2>&1 &
		echo ""
		echo "Syncing is done, but the searcher database is still syncing in the background... (psall eix)"
		return $?
	fi

	if [ "$dyDetectedDistro" == "FreeBSD" ]; then
		if [ "$dyAltPkgManager" == "portmaster" ]; then
			dyFreeBSDCheckPortsUtilsOld
		fi
		if [ "$dyAltPkgManager" == "synth" ]; then
			dyFreeBSDCheckPortsUtils
		fi
        $hachreAliasesRoot portsnap fetch update
		return $?
	fi

	echo "This command is not supported on your platform."
}

function dyv {
	if [ "$dyDetectedDistro" == "sabayon" ]; then
		equo deptest
		equo libtest
		equo conf update
		return $?
	fi

	if [ "$dyDetectedDistro" == "osx-brew" ]; then
		brew doctor
		return $?
	fi

	if [ "$dyDetectedDistro" == "arch" ]; then
		which yay 1>/dev/null 2>&1
		if [ "$?" != "0" ]; then
			echo "Error: This command is not available unless you run dySetup."
			return 1
		fi

		$_ha_arch_pm -Ps
		return $?
	fi


	if [ "$dyDetectedDistro" == "opensuse" ]; then
		$hachreAliasesRoot zypper verify
		return $?
	fi

	echo "This command is not supported on your platform."
}

function dyw {
	if [ "$dyDetectedDistro" == "ubuntu" ]; then
		apt-mark showmanual
		return $?
	fi

	if [ "$dyDetectedDistro" == "gentoo" ]; then
		cat /var/lib/portage/world
		return $?
	fi

	if [ "$dyDetectedDistro" == "alpine" ]; then
		cat /etc/apk/world
		return $?
	fi

	if [ "$dyDetectedDistro" == "FreeBSD" ]; then
		$hachreAliasesRoot pkg info
		return $?
	fi

	echo "This command is not supported on your platform."
}

function dyu {
	if [ "$dyDetectedDistro" == "gentoo" ]; then
        # If the last sync was less than 120 mins ago, skip the new sync
        if test "`find /usr/portage/metadata/timestamp.chk -mmin +120`"; then
            touch /usr/portage/metadata/timestamp.chk
        else
            skip="1"
        fi
    fi

	# CentOS does this on its own
	if [ "$dyDetectedDistro" == "CentOS" ]; then
		skip="1"
	fi

    # We want to ensure we are synced before updating
    if [ -z "$skip" ]; then
        dyx
    fi

	# Platform specific
	if [ "$dyDetectedDistro" == "sabayon" ]; then
		equo upgrade -av  $*
		if [ "$?" != "0" ]; then
			return 1
		fi
		equo conf update
		return $?
	fi

	if [ "$dyDetectedDistro" == "gentoo" ]; then
		emerge -uD -kk --newuse --with-bdeps=y --binpkg-respect-use=y @world -av
		if [ "$?" == "0" ]; then
			emerge --depclean -av
			etc-update
		fi
		return $?
	fi

	if [ "$dyDetectedDistro" == "arch" ]; then
    	$_ha_arch_pm -Suy --needed $@
		yay -h 1>/dev/null 2>&1
		if [ "$?" == "0" ]; then
			echo "Removing unneeded packages..."
			$_ha_arch_pm -Yc $@
		fi
		return $?
	fi

	if [ "$dyDetectedDistro" == "alpine" ]; then
		apk upgrade -i $*
		return $?
	fi

	if [ "$dyDetectedDistro" == "osx-brew" ]; then
		brew upgrade --cleanup
		return $?
	fi

	if [ "$dyDetectedDistro" == "opensuse" ]; then
        echo "Info: Occasionally you should also manually run 'zypper dup' and be extra careful when you have 3rd party repos enabled."
        #zypper patch -y -l --no-recommends --updatestack-only
		$hachreAliasesRoot zypper up -l --no-recommends
        #zypper patch -y -l --no-recommends
		return $?
	fi

	if [ "$dyDetectedDistro" == "windows" ] || [ "$dyDetectedDistro" == "ubuntu" ]; then
		$hachreAliasesRoot apt full-upgrade
		$hachreAliasesRoot apt autoremove

		if [ "$dyDetectedDistro" == "windows" ]; then
			which youtube-dl >/dev/null 2>&1
			if [ "$?" == "0" ]; then
				dyi python-setuptools
				sudo easy_install pip
				sudo pip install --upgrade youtube-dl
			fi
		fi

		return $?
	fi

	if [ "$dyDetectedDistro" == "FreeBSD" ]; then
    $hachreAliasesRoot pkg upgrade
		$hachreAliasesRoot pkg autoremove
		return $?
	fi

	if [ "$dyDetectedDistro" == "CentOS" ]; then
    $hachreAliasesRoot $(dyYumCmd) update | tee
		ret="$?"
		if [ "$?" == "0" ]; then
			$hachreAliasesRoot $(dyYumCmd) autoremove -y | tee
		fi
		return $ret
	fi

	echo "This command is not supported on your platform."
}

function dyus {
	# Security updates only
	if [ "$dyDetectedDistro" == "gentoo" ]; then
        echo "Checking for security issues..."
        $root glsa-check -f affected
        return $?
    fi

	if [ "$dyDetectedDistro" == "sabayon" ]; then
        $root equo sec update
        $root equo sec install
        return $?
    fi

	if [ "$dyDetectedDistro" == "opensuse" ]; then
		echo "Checking and installing security updates only..."
		$hachreAliasesRoot zypper patch -l --no-recommends --updatestack-only -y
	    $hachreAliasesRoot zypper patch -l --no-recommends -g security -y --replacefiles
		return $?
	fi

	if [ "$dyDetectedDistro" == "FreeBSD" ]; then
        $hachreAliasesRoot pkg audit -F
		return $?
	fi

	if [ "$dyDetectedDistro" == "CentOS" ]; then
		$hachreAliasesRoot $(dyYumCmd) update --security | tee
		return $?
	fi


	echo "This command is not supported on your platform."
}

function dyuu {
	if [ "$dyDetectedDistro" == "sabayon" ]; then
        # If the last sync was less than 15 mins ago, skip the new sync
        if test "`find /usr/portage/metadata/timestamp.chk -mmin +15`"; then
            touch /usr/portage/metadata/timestamp.chk
			dyxx
		fi
        remerge -avuN $(equo query revisions 9999 -q | grep -v automake)
        return $?

#		echo "Info: Automated secondary repo upgrading is not supported on this platform."
#		echo ""
#		echo "Instruction for manual update are as follows:"
#		echo " 1. Look at /etc/entropy/packages/package.mask"
#		echo " 2. Run each of those packages against emerge -pv <packagename>"
#		echo " 3. Use dyii on the packages that are outdated to update them."
#		return 1
	fi

	if [ "$dyDetectedDistro" == "sabayon" ]; then
		equo install -av $*
		if [ "$?" != "0" ]; then
			echo ""
			echo "If equo is talking about masked packages it means that you have"
			echo "previously used dyii to install this package and it has been masked"
			echo "so that equo will not overwrite it with its own version."
			echo ""
			echo "You can either use dyif, 'equo unmask <package>' or dyr to uninstall first."
			return 1
		fi
		equo conf update
		return $?
	fi

	if [ "$dyDetectedDistro" == "gentoo" ]; then
		emerge -avkk --quiet-build=y --binpkg-respect-use=y $*
		return $?
	fi

	if [ "$dyDetectedDistro" == "opensuse" ]; then
		$hachreAliasesRoot zypper in -l --no-recommends $*
		return $?
	fi

	if [ "$dyDetectedDistro" == "FreeBSD" ]; then
		if [ "$dyAltPkgManager" == "portmaster" ]; then
			dyxx
			dyFreeBSDCheckPortsUtilsOld
			echo "This command is not very useful. You should use dyii 'package' or dyu instead."
			sleep 3
	        $hachreAliasesRoot portmaster -adwv
			#$hachreAliasesRoot pkg autoremove
			return $?
		fi
		if [ "$dyAltPkgManager" == "synth" ]; then
			dyFreeBSDCheckPortsUtils
			dyxx
			$hachreAliasesRoot synth upgrade-system
			return $?
		fi
	fi

	echo "This command is not supported on your platform."
}
function dyi {
	if [ -z "$1" ]; then
		echo "Usage: dyi <package name>"
		return 1
	fi

	if [ "$dyDetectedDistro" == "sabayon" ]; then
		equo install -av $*
		if [ "$?" != "0" ]; then
			echo ""
			echo "If equo is talking about masked packages it means that you have"
			echo "previously used dyii to install this package and it has been masked"
			echo "so that equo will not overwrite it with its own version."
			echo ""
			echo "You can either use dyif, 'equo unmask <package>' or dyr to uninstall first."
			return 1
		fi
		equo conf update
		return $?
	fi

	if [ "$dyDetectedDistro" == "gentoo" ]; then
		emerge -avkk --quiet-build=y --binpkg-respect-use=y $*
		return $?
	fi

	if [ "$dyDetectedDistro" == "arch" ]; then
		$_ha_arch_pm -Suy --needed $@
		return $?
	fi

	if [ "$dyDetectedDistro" == "alpine" ]; then
		apk add -i $*
		return $?
	fi

	if [ "$dyDetectedDistro" == "osx-brew" ]; then
		if [ ! -z "$2" ]; then
			echo "Error: 'osx-brew' supports only one package parameter."
			return 1
		fi
		brew install "$1"
		return $?
	fi

	if [ "$dyDetectedDistro" == "opensuse" ]; then
		$hachreAliasesRoot zypper in -l --no-recommends $*
		return $?
	fi

   	if [ "$dyDetectedDistro" == "windows" ] || [ "$dyDetectedDistro" == "ubuntu" ]; then
		$hachreAliasesRoot apt install $*
		return $?
	fi

	if [ "$dyDetectedDistro" == "FreeBSD" ]; then
        $hachreAliasesRoot pkg install $*
		return $?
	fi

	if [ "$dyDetectedDistro" == "CentOS" ]; then
        $hachreAliasesRoot $(dyYumCmd) install $* | tee
		return $?
	fi

	echo "This command is not supported on your platform."
}
function dyif {
	if [ -z "$1" ]; then
		echo "Usage: dyif <package name>"
		return 1
	fi

	if [ "$dyDetectedDistro" == "sabayon" ]; then
		equo unmask $* 1>/dev/null 2>&1
		dyi -av $*
		return $?
	fi

	if [ "$dyDetectedDistro" == "gentoo" ]; then
		dyi --usepkg=n $*
		return $?
	fi

	if [ "$dyDetectedDistro" == "osx-brew" ]; then
		dyi $*
		return $?
	fi

	if [ "$dyDetectedDistro" == "alpine" ]; then
		apk add -i --force-broken-world --force-overwrite --force-refresh $*
		return $?
	fi

	if [ "$dyDetectedDistro" == "arch" ]; then
		$_ha_arch_pm -S --overwrite / $@
		return $?
	fi

	if [ "$dyDetectedDistro" == "opensuse" ]; then
		$hachreAliasesRoot zypper in -fl --no-recommends $*
		return $?
	fi

	echo "This command is not supported on your platform."
}
function dyii {
	if [ -z "$1" ]; then
		echo "Usage: dyii <package name>"
		return 1
	fi

	if [ "$dyDetectedDistro" == "sabayon" ]; then
		if [ ! -z "$2" ]; then
			echo "Error: Please install only one package at once in sabayon emerge mode..."
			return 1
		fi

		# Install build-deps
		equo install --bdeps --onlydeps -av $1

		# Emerge the package
		/usr/bin/emerge -avkk $1
		if [ "$?" != "0" ]; then
			return 1
		fi

		# Sync emerge state to equo
		equo rescue spmsync

		# Make equo ignore the installed package
		#longname=`equery l -F \$category/\$name "$1"`
		#cat /etc/entropy/packages/package.mask | grep "$longname"
		#if [ "$?" != "0" ]; then
		#	echo "$longname" >> /etc/entropy/packages/package.mask.d/50-hachreAliases
		#fi
		equo mask "$1"

		# Set up equo not to downgrade emerged packages
		cat /etc/entropy/client.conf | grep "ignore-spm-downgrades" | grep "enable"
		if [ "$?" != "0" ]; then
			echo "# added by hachreAliases" >> /etc/entropy/client.conf
			echo "ignore-spm-downgrades = enable" >> /etc/entropy/client.conf
		fi

		equo conf update

		echo ""
		echo "Package '$1' is now no longer going to be handled by equo and system updates"
		echo ""
		echo "You can elect to add it into equo again by typing 'equo unmask $1' however if"
		echo "the version is equal in equo's repository this will immediately switch the package"
		echo "back to the entropy version instead of your emerged version on the next system upgrade"
		echo ""
		echo "The list of packages that are hidden for equo can be found in the following location:"
		echo "/etc/entropy/packages/package.mask"
		echo ""
		echo "It is recommended that you use emerge / dyuu or dyii to upgrade packages on that list"
		return $?
	fi

	if [ "$dyDetectedDistro" == "opensuse" ]; then
        $hachreAliasesRoot zypper lr packman 1>/dev/null 2>&1
        if [ "$?" != "0" ]; then
            echo "Error: Packman repo is not installed."
            echo "Check the following URL for more info: https://en.opensuse.org/Additional_package_repositories#Packman"
            return 1
        fi

        # Enable the Packman repo if it is off
        $hachreAliasesRoot zypper mr -e packman

        # Install
		$hachreAliasesRoot zypper in -fl --no-recommends $*

        # Disable the Packman again
        $hachreAliasesRoot zypper mr -d packman
		return $?
	fi

	if [ "$dyDetectedDistro" == "FreeBSD" ]; then
		if [ "$dyAltPkgManager" == "portmaster" ]; then
			dyFreeBSDCheckPortsUtilsOld
			path=`dyFreeBSDResolvePortPathOld $*`
			$hachreAliasesRoot portmaster --force-config "$path"
			return $?
		fi
		if [ "$dyAltPkgManager" == "synth" ]; then
			dyFreeBSDCheckPortsUtils
			path=$(dyFreeBSDResolvePortPath $1)
			$hachreAliasesRoot synth install $path
			return $?
		fi
	fi

	echo "This command is not supported on your platform. This either means dyi already handles it or it won't work at all."
}

function dyl {
	if [ -z "$1" ]; then
		echo "Usage: dyl <package name>"
		return 1
	fi

	if [ "$dyDetectedDistro" == "arch" ]; then
		$_ha_arch_pm -Qlq $@ | less -rEFXKn
		return $?
	fi

	if [ "$dyDetectedDistro" == "FreeBSD" ]; then
		$hachreAliasesRoot pkg info --list-file $@
		return $?
	fi

	echo "This comand is not supported on your platform."
}

function dyo {
	if [ -z "$1" ]; then
		echo "Usage: dyo <file>"
		return 1
	fi

	if [ "$dyDetectedDistro" == "ubuntu" ]; then
		dpkg -S $*
		return $?
	fi

	if [ "$dyDetectedDistro" == "arch" ]; then
		$_ha_arch_pm -Qo $@
		return $?
	fi

	if [ "$dyDetectedDistro" == "gentoo" ]; then
		equery belongs $*
		return $?
	fi

	if [ "$dyDetectedDistro" == "sabayon" ]; then
		equo query belongs $*
		return $?
	fi

	if [ "$dyDetectedDistro" == "alpine" ]; then
		apk info --who-owns $*
		return $?
	fi

	echo "This comand is not supported on your platform."
}

function dyr {
	if [ -z "$1" ]; then
		echo "Usage: dyr <package name>"
		return 1
	fi

	if [ "$dyDetectedDistro" == "sabayon" ]; then
		equo remove --deep -av $*
		equo unmask $* 1>/dev/null 2>/dev/null
		return $?
	fi

	if [ "$dyDetectedDistro" == "gentoo" ]; then
		emerge --depclean -av $*
		return $?
	fi

	if [ "$dyDetectedDistro" == "arch" ]; then
		$_ha_arch_pm -Rcs $@
		return $?
	fi

	if [ "$dyDetectedDistro" == "alpine" ]; then
		apk del -i $*
		return $?
	fi

	if [ "$dyDetectedDistro" == "osx-brew" ]; then
		if [ ! -z "$2" ]; then
			echo "Error: 'osx-brew' supports only one package parameter."
			return 1
		fi
		brew uninstall "$1"
		return $?
	fi

	if [ "$dyDetectedDistro" == "opensuse" ]; then
		$hachreAliasesRoot zypper rm -u $*
		return $?
	fi

   	if [ "$dyDetectedDistro" == "windows" ] || [ "$dyDetectedDistro" == "ubuntu" ]; then
		$hachreAliasesRoot apt remove $*
		$hachreAliasesRoot apt autoremove
		return $?
	fi

	if [ "$dyDetectedDistro" == "FreeBSD" ]; then
    	$hachreAliasesRoot pkg remove $*
		$hachreAliasesRoot pkg autoremove
		return $?
	fi

	if [ "$dyDetectedDistro" == "CentOS" ]; then
	    $hachreAliasesRoot $(dyYumCmd) remove $* | tee
	    $hachreAliasesRoot $(dyYumCmd) autoremove -y | tee
		return $?
	fi

	echo "This comand is not supported on your platform."
}
function dyrf {
	if [ -z "$1" ]; then
		echo "Usage: dyrf <package name>"
		return 1
	fi

	if [ "$dyDetectedDistro" == "sabayon" ]; then
		dyr --force-system $*
		return $?
	fi

	if [ "$dyDetectedDistro" == "arch" ]; then
		$_ha_arch_pm -R $@
		return $?
	fi

	if [ "$dyDetectedDistro" == "gentoo" ]; then
		emerge --unmerge -av $*
		return $?
	fi

	if [ "$dyDetectedDistro" == "alpine" ]; then
		apk del -i --purge $*
		return $?
	fi

	if [ "$dyDetectedDistro" == "osx-brew" ]; then
		if [ ! -z "$2" ]; then
			echo "Error: 'osx-brew' supports only one package parameter."
			return 1
		fi
		brew uninstall --force "$1"
		return $?
	fi

	if [ "$dyDetectedDistro" == "windows" ] || [ "$dyDetectedDistro" == "ubuntu" ]; then
		$hachreAliasesRoot apt-get purge $*
		$hachreAliasesRoot apt autoremove
		return $?
	fi

	echo "This command is not supported on your platform."
}
function dys {
	if [ -z "$1" ]; then
		echo "Usage: dys <package name>"
		return 1
	fi

	if [ "$dyDetectedDistro" == "gentoo" ]; then
		which -p eix > /dev/null 2>&1
		if [ "$?" != "0" ]; then
			# Install eix
			dyi eix

            # Emerge WebRsync
            emerge-webrsync
            emerge --sync

   			# Upgrade eix cache
			eixupdate
		fi
		eix -F $* | less -rEFXKn
		return $?
	fi

	if [ "$dyDetectedDistro" == "sabayon" ]; then
		equo search --color $* | less -rEFXKn
		return $?
	fi

	if [ "$dyDetectedDistro" == "arch" ]; then
		yay -h 1>/dev/null 2>&1
		if [ "$?" == "0" ]; then
			$_ha_arch_pm -Ss $@ | tac | less -rEFXKn
			return $?
		fi

		$_ha_arch_pm -Ss $@ | less -rEFXKn
		return $?
	fi

	if [ "$dyDetectedDistro" == "osx-brew" ]; then
		brew search $* | less -rEFXKn
		return $?
	fi

	if [ "$dyDetectedDistro" == "opensuse" ]; then
		$hachreAliasesRoot zypper search -s $* | less -rEFXKn
		return $?
	fi

	if [ "$dyDetectedDistro" == "alpine" ]; then
		apk search -a $* | sort | uniq | less -rEFXKn
		return $?
	fi

	if [ "$dyDetectedDistro" == "windows" ] || [ "$dyDetectedDistro" == "ubuntu" ]; then
		$hachreAliasesRoot apt-cache search $* | less -rEFXKn
		return $?
	fi

	if [ "$dyDetectedDistro" == "FreeBSD" ]; then
        $hachreAliasesRoot pkg search $* | less -rEFXKn
		return $?
	fi

	if [ "$dyDetectedDistro" == "CentOS" ]; then
        $hachreAliasesRoot $(dyYumCmd) search $* | less -rEFXKn
		return $?
	fi

	echo "This command is not supported on your platform."
}

function dyss {
	if [ -z "$1" ]; then
		echo "Usage: dyss <package name>"
		return 1
	fi

	if [ "$dyDetectedDistro" == "sabayon" ] || [ "$dyDetectedDistro" == "gentoo" ]; then
		dys -R $*

		echo ""
		echo "Info: To install a package from this list:"
		echo " 1. Add the repo by doing 'layman -a <reponame>'"
		echo " 2. Then use 'dyii <packagename>'"
		return $?
	fi

	if [ "$dyDetectedDistro" == "arch" ]; then
		which yay 1>/dev/null 2>&1
		if [ "$?" != "0" ]; then
			echo "Error: This command is not supported unless you first run dySetup."
			return 1
		fi

		$_ha_arch_pm -Ss $@ --aur | less -rEFXKn
		return $?
	fi

	if [ "$dyDetectedDistro" == "opensuse" ]; then
        $hachreAliasesRoot zypper lr packman 1>/dev/null 2>&1
        if [ "$?" != "0" ]; then
            echo "Error: Packman repo is not installed."
            echo "Check the following URL for more info: https://en.opensuse.org/Additional_package_repositories#Packman"
            return 1
        fi

        # Enable the Packman repo if it is off
        $hachreAliasesRoot zypper mr -e packman

        # Searching
        $hachreAliasesRoot zypper search -s $*
        val=$?

        # Disable the Packman again
        $hachreAliasesRoot zypper mr -d packman

		return $val
	fi

	if [ "$dyDetectedDistro" == "FreeBSD" ]; then
		if [ "$dyAltPkgManager" == "portmaster" ]; then
			dyFreeBSDCheckPortsUtilsOld
			$hachreAliasesRoot psearch -n $*
			return $?
		fi
		if [ "$dyAltPkgManager" == "synth" ]; then
			dyFreeBSDCheckPortsUtils
			$hachreAliasesRoot psearch -no $*
			return $?
		fi
	fi

	echo "This command is not supported on your platform."
}

#
# End of dynaloop unified package management commands
#

# INIT Helpers - TODO Extensive refactor, rewrite of this section
# Gentoo openrc specific init helpers
which systemctl >/dev/null 2>&1
if [ "$?" != "0" ]; then
	if [ "$dyDetectedDistro" == "alpine" ] || [ "$dyDetectedDistro" == "gentoo" ] || [ "$dyDetectedDistro" == "FreeBSD" ] || [ "$dyDetectedDistro" == "ubuntu" ]; then
		initdir=""
		if [ "$dyDetectedDistro" == "alpine" ] || [ "$dyDetectedDistro" == "gentoo" ] || [ "$dyDetectedDistro" == "ubuntu" ]; then
			initdir="/etc/init.d"
		fi
		if [ "$dyDetectedDistro" == "FreeBSD" ]; then
			initdir="/etc/rc.d"
			initdir2="/usr/local/etc/rc.d"
		fi

		function existsScript {
			if [ ! -f "$initdir2/$1" ]; then
				if [ ! -f "$initdir/$1" ]; then
					echo "Error: Given service '$1' not found. Try sfind..."
					return 1
				fi
			fi
			return 0
		}

		function start {
			if [ -z "$1" ]; then
				echo "Usage: start <service>"
				return 1
			fi

			existsScript "$1" || return $?

			if [ "$dyDetectedDistro" == "gentoo" ] || [ "$dyDetectedDistro" == "alpine" ]; then
				$initdir/$1 start
			fi
			if [ "$dyDetectedDistro" == "ubuntu" ] ; then
				service $1 start
			fi
			
			if [ "$dyDetectedDistro" == "FreeBSD" ]; then
				serviceCmd="start"
				grep -i $1_enable=\"YES\" /etc/rc.conf 1>/dev/null 2>&1
				if [ "$?" != "0" ]; then
					serviceCmd="onestart"
				fi
				service $1 $serviceCmd
			fi
		}

		function stop {
			if [ -z "$1" ]; then
				echo "Usage: stop <service>"
				return 1
			fi

			existsScript "$1" || return $?

			if [ "$dyDetectedDistro" == "gentoo" ] || [ "$dyDetectedDistro" == "alpine" ]; then
				$initdir/$1 stop
			fi
			if [ "$dyDetectedDistro" == "ubuntu" ] ; then
				service $1 stop
			fi

			if [ "$dyDetectedDistro" == "FreeBSD" ]; then
				serviceCmd="stop"
				grep -i $1_enable=\"YES\" /etc/rc.conf 1>/dev/null 2>&1
				if [ "$?" != "0" ]; then
					serviceCmd="onestop"
				fi
				service $1 $serviceCmd
			fi
		}

		function restart {
			if [ -z "$1" ]; then
				echo "Usage: restart <service>"
				return 1
			fi

			existsScript "$1" || return $?

			if [ "$dyDetectedDistro" == "gentoo" ] || [ "$dyDetectedDistro" == "alpine" ]; then
				$initdir/$1 restart
			fi
			if [ "$dyDetectedDistro" == "ubuntu" ] ; then
				service $1 restart
			fi

			if [ "$dyDetectedDistro" == "FreeBSD" ]; then
				serviceCmd="restart"
				grep -i $1_enable=\"YES\" /etc/rc.conf 1>/dev/null 2>&1
				if [ "$?" != "0" ]; then
					serviceCmd="onerestart"
				fi
				service $1 $serviceCmd
			fi
		}

		function reload {
			if [ -z "$1" ]; then
				echo "Usage: reload <service>"
				return 1
			fi

			existsScript "$1" || return $?

			if [ "$dyDetectedDistro" == "gentoo" ] || [ "$dyDetectedDistro" == "alpine" ]; then
				$initdir/$1 reload
			fi
			if [ "$dyDetectedDistro" == "FreeBSD" ] || [ "$dyDetectedDistro" == "ubuntu" ] ; then
				service $1 reload
			fi

			if [ "$dyDetectedDistro" == "FreeBSD" ]; then
				serviceCmd="reload"
				grep -i $1_enable=\"YES\" /etc/rc.conf 1>/dev/null 2>&1
				if [ "$?" != "0" ]; then
					serviceCmd="onereload"
				fi
				service $1 $serviceCmd
			fi
		}

		function status {
			if [ -z "$1" ]; then
				echo "Usage: status <service>"
				return 1
			fi

			existsScript "$1" || return $?

			if [ "$dyDetectedDistro" == "gentoo" ] || [ "$dyDetectedDistro" == "alpine" ]; then
				$initdir/$1 status
			fi
			if [ "$dyDetectedDistro" == "ubuntu" ] ; then
				service $1 status
			fi

			if [ "$dyDetectedDistro" == "FreeBSD" ]; then
				serviceCmd="status"
				grep -i $1_enable=\"YES\" /etc/rc.conf 1>/dev/null 2>&1
				if [ "$?" != "0" ]; then
					serviceCmd="onestatus"
				fi
				service $1 $serviceCmd
			fi
		}

		function senable {
			if [ "$dyDetectedDistro" == "gentoo" ] || [ "$dyDetectedDistro" == "alpine" ]; then
				if [ -z "$1" ]; then
					echo "Usage: senable [service] (runlevel)"
					return 1
				fi

				existsScript "$1" || return $?

				runlevel="default"
				if [ ! -z "$2" ]; then
					runlevel="$2"
				fi

				rc-update add "$1" "$runlevel"
				return $?
			fi

			if [ "$dyDetectedDistro" == "FreeBSD" ]; then
				echo "$1 has been enabled to run on system startup, but not started right now."
				grep "$1_enabled" /etc/rc.conf 1>/dev/null 2>&1
				if [ "$?" != 0 ]; then
					echo "$1_enable" >> /etc/rc.conf
				fi
				gsed -i "/$1_enable/c$1_enable=\"YES\"" /etc/rc.conf
				return $?
			fi

			echo "This command is not supported on your platform."
		}

		function sdisable {
			if [ "$dyDetectedDistro" == "gentoo" ] || [ "$dyDetectedDistro" == "alpine" ]; then
				if [ -z "$1" ]; then
					echo "Usage: sdisable [service] (runlevel)"
					return 1
				fi

				existsScript "$1" || return $?

				runlevel="default"
				if [ ! -z "$2" ]; then
					runlevel="$2"
				fi

				rc-update del "$1" "$runlevel"
			fi

			if [ "$dyDetectedDistro" == "FreeBSD" ]; then
				echo "$1 has been disabled to run on system startup, but not stopped right now."
				grep "$1_enable" /etc/rc.conf 1>/dev/null 2>&1
				if [ "$?" != 0 ]; then
					echo "$1_enable" >> /etc/rc.conf
				fi
				gsed -i "/$1_enable/c$1_enable=\"NO\"" /etc/rc.conf
				return $?
			fi

			echo "This command is not supported on your platform."
		}

		function dyFreeBSDsstatus {
			function echook() {
				echo -ne " [ `echoGreen OK` ] "
			}
			function echofail() {
				echo -ne " [`echoRed FAIL`] "
			}
			function echoexit() {
				echo -ne " [`echoYellow EXIT`] "
			}

			sIPS="$IPS"
			IPS=$'\n'

			echo "Status for enabled services:"

			#tmp=$(mktemp)
			#find /etc/rc.d -type f >> $tmp
			#find /usr/local/etc/rc.d -type f >> $tmp

			enabledServices=$(mktemp)
			service -e > $enabledServices
			for service in $(cat $enabledServices); do
				# Get clean servicename.
				serviceName=`basename "$service"`
				#serviceName=${serviceName/.service/}

				# Find out if it is running
				state=$(status "$serviceName" 2>&1)
				#state=${state/SubState=/}

				# Prepare the state checker
				stateknown="false"

				# Check for false positives
				enabled="1"
				grep "$serviceName"_enable=\"YES\" /etc/rc.conf 1>/dev/null 2>&1
				if [ "$?" != "0" ]; then
					enabled="0"
				fi

				# Whitelist
				if [ "$serviceName" == "ip6addrctl" ]; then
					echook
					stateknown="true"
				fi

				# Output the sheet.
				if [ "$stateknown" != "true" ]; then
					if [[ "$state" == *"unknown directive"* ]]; then
						continue
					fi
					if [[ "$state" == *"is running"* ]]; then
						echook
						stateknown="true"
					fi
					if [[ "$state" == *"exit"* ]]; then
						echoexit
						stateknown="true"
					fi
					if [ "$stateknown" != "true" ]; then
						if [ "$enabled" == "0" ]; then
							continue
						fi
						echofail
					fi
				fi

				echo "$serviceName"
			done

			echo "Status for non-enabled services:"
			
			tmp=$(mktemp)
			find /etc/rc.d -type f >> $tmp
			find /usr/local/etc/rc.d -type f >> $tmp
			cat $tmp | sort | uniq > $tmp.2
			mv $tmp.2 $tmp

			for service in $(cat $enabledServices); do
				cat $tmp | grep -vi "$service" > $tmp.2
				mv $tmp.2 $tmp
			done
			
			for service in $(cat $tmp); do
				# Get clean servicename.
				serviceName=`basename "$service"`
				#serviceName=${serviceName/.service/}

				# Find out if it is running
				state=$(status "$serviceName" 2>&1)
				#state=${state/SubState=/}

				# Prepare the state checker
				stateknown="false"

				# Output the sheet.
				if [ "$stateknown" != "true" ]; then
					if [[ "$state" == *"unknown directive"* ]]; then
						continue
					fi
					if [[ "$state" == *"is running"* ]]; then
						echook
						stateknown="true"
					fi
					if [[ "$state" == *"exit"* ]]; then
						echoexit
						stateknown="true"
					fi
					if [ "$stateknown" != "true" ]; then
						continue
						#echofail
					fi
				fi

				echo "$serviceName"
			done

			rm "$tmp"
			rm "$enabledServices"
			IPS="$sIPS"
		}

		function sstatus {
			if [ "$dyDetectedDistro" == "gentoo" ] || [ "$dyDetectedDistro" == "alpine" ]; then
				rc-status
				return $?
			fi

			if [ "$dyDetectedDistro" == "FreeBSD" ]; then
				dyFreeBSDsstatus
				return $?
			fi

			echo "This command is not supported on your platform."
		}

		function sfind {
			sPWD=`pwd`

			cd $initdir

			if [ -z "$1" ]; then
				find . -type f
				return 0
			fi

			find . -type f -iname "*$1*"

			if [ ! -z "$initdir2" ]; then
				cd $initdir2

				if [ -z "$1" ]; then
					find . -type f
					return 0
				fi

				find . -type f -iname "*$1*"				
			fi

			cd "$sPWD"

			return 0
		}
	fi
fi

# Gentoo flag editing
if [ "$dyDetectedDistro" == "gentoo" ] || [ "$dyDetectedDistro" == "sabayon" ]; then
    function hachreAliasesinstallFlaggie() {
        which flaggie 1>/dev/null 2>&1
        if [ "$?" != "0" ]; then
            dyi flaggie
        fi
        $root mkdir /etc/portage/package.use/ >/dev/null 2>&1
        $root mkdir /etc/portage/package.accept_keywords/ >/dev/null 2>&1
        $root touch /etc/portage/package.use/z-hachreAliases >/dev/null 2>&1
        $root touch /etc/portage/package.accept_keywords/z-hachreAliases >/dev/null 2>&1
    }

    function gunlock() {
        hachreAliasesinstallFlaggie
        if [ -z "$1" ]; then
            echo "Usage: gunlock <packagename>"
            return 1
        fi

        $root flaggie "$1" +**
        return $?
    }

    function glock() {
        hachreAliasesinstallFlaggie
        if [ -z "$1" ]; then
            echo "Usage: glock <packagename>"
            return 1
        fi

        $root flaggie "$1" -**
        return $?
    }

    function guse() {
        hachreAliasesinstallFlaggie
        if [ -z "$1" ]; then
            echo "Usage: guse <packagename> [+flag1 -flag2 ...] or [--reset]"
            echo "If you don't give flags the current flags will be displayed."
            return 1
        fi

        # Apply Changes
        changes=""
        if [ ! -z "$2" ]; then
            if [ "$2" == "--reset" ]; then
                $root flaggie "$1" %use::
            else
                $root flaggie $@
            fi
            changes="1"
        fi

        # Show what has changed
        if [ "$?" == "0" ]; then
			which equery >/dev/null 2>&1
			if [ "$?" != "0" ]; then
				dyi gentoolkit
			fi
            equery u -i "$1"
            retval=$?

            if [ ! -z "$changes" ]; then
                echo ""
                echo "You can now use 'dyu' to apply these new use settings"
            fi

            return $retval
        fi
    }
fi

# Easy Color Output
function echoRed() {
	echo -ne "\e[91m$1\e[0m"
}
function echoGreen() {
	echo -ne "\e[92m$1\e[0m"
}
function echoYellow() {
	echo -ne "\e[93m$1\e[0m"
}

# Arch specific commands
if [ "$dyDetectedDistro" == "arch" ]; then
	alias mirrorlist="curl -s 'https://www.archlinux.org/mirrorlist/?country=DE&protocol=https&use_mirror_status=on' | sed -e 's/^#Server/Server/' -e '/^#/d' | rankmirrors -n 5 - > /etc/pacman.d/mirrorlist"
fi

#
# Systemctl
#

which systemctl >/dev/null 2>&1
if [ "$?" == "0" ]; then
	function sreload() {
		systemctl daemon-reload
	}
	function stop() {
		sreload
		systemctl stop $@
	}
	function restart() {
		sreload
		systemctl restart $@
	}
	function reload() {
		sreload
		systemctl reload $@
	}
	function status() {
		sreload
		systemctl status $@
	}
	function viewlog {
		# Views Journalctl log in Less
		if [ -z "$1" ]; then
			echo "Usage: viewlog <unit name> [... optional parameters for journalctl ...]"
			echo "Unit name can be 'all' to see the log of all services combined."
			echo "See also: followlog"
			return 1
		fi
		if [ "$1" == "all" ]; then
			service=""
		else
			service="-u $1"
		fi
		journalctl --since today --no-pager $service | less -rEFXKn
	}
	alias showlog="viewlog"
	function followlog {
		# Follow JournalCtl log in realtime
		if [ -z "$1" ]; then
			echo "Usage: followlog <unit name> [... optional parameters for journalctl ...]"
			echo "Unit name can be 'all' to see the log of all services combined."
			echo "See also: viewlog"
			return 1
		fi
		if [ "$1" == "all" ]; then
			service=""
		else
			service="-u $1"
		fi
		journalctl -n 500 -f $service
	}
	function start {
		sreload
		systemctl start $@
		returnVal=$?
		if [ "$returnVal" != "0" ]; then
			echo ""
			echoRed " === Process '$@' failed to start. ===\n"
			systemctl status $@
			echo ""
			echoYellow " These are the last 10 entries of all logs:\n"
			journalctl -n 10 --no-pager
			echo ""
			echoYellow " These are the last 10 entries of the '$@' log:\n"
			journalctl -n 10 --no-pager -u $@
			echo ""
			echo "If you need to view more of the log, use 'viewlog $@' or 'viewlog all'."
		fi
		return $returnVal
	}
	function sfind {
		if [ -z "$1" ]; then
			echo "Usage: sfind <pattern>"
			return 1
		fi

		searchterm="$@"

		sfinddir="/lib/systemd"
		if [ ! -d "$sfinddir" ]; then
			sfinddir="/usr/lib64/systemd"
		fi
		if [ ! -d "$sfinddir" ]; then
			sfinddir="/usr/lib/systemd"
		fi
		spwd=`pwd`
		cd "$sfinddir"

		echo "Searching in '$sfinddir'..."
		echo " If you want to customize one of these, copy them to /etc/systemd, customize there and use sreload"
		echo ""
		find . -iname "*${searchterm}*"

		cd "$spwd"
	}
	function sdisable {
		sreload
		tmpfile=`mktemp`
		hachreAliasesSystemctlOutput=`systemctl is-enabled "$1" 2>"$tmpfile"`
		if [ "$?" != "0" ]; then
			if [ -z "$hachreAliasesSystemctlOutput" ]; then
				# Output was 1, and there was no stdout means the unit file cannot be found.
				cat "$tmpfile"
				rm "$tmpfile" >/dev/null 2>&1
				return 1
			else
				# Output was 1 but there was stdout, means the unit is already disabled
				echo "Warning: The given unit was already disabled."
				rm "$tmpfile" >/dev/null 2>&1
				return 0
			fi
		fi

		# The output is 0, we can now simply disable the unit.
		systemctl disable $@
		systemctl reset-failed $@ >/dev/null 2>&1
		systemctl disable $@ >/dev/null 2>&1
	}
	function senable() {
		sreload
		systemctl reset-failed $@ >/dev/null 2>&1
		systemctl enable -f $@
		systemctl reenable $@ >/dev/null 2>&1
	}
	function sstatus() {
		function echook() {
			echo -ne " [ `echoGreen OK` ] "
		}
		function echofail() {
			echo -ne " [`echoRed FAIL`] "
		}
		function echoexit() {
			echo -ne " [`echoYellow EXIT`] "
		}

		sIPS="$IPS"
		IPS=$'\n'

		echo "System status for multi-user.target.wants:"

		for service in `find /etc/systemd/system/multi-user.target.wants/*service`; do
			# Get clean servicename.
			serviceName=`basename "$service"`
			serviceName=${serviceName/.service/}

			# Find out if it is running
			state=`systemctl show "$serviceName" --plain --no-pager | grep -i "SubState\="`
			state=${state/SubState=/}

			# Our OK state
			stateknown="false"

			# Find out the type (because on oneshot we need the success flag)
			type=`systemctl show "$serviceName" --plain --no-pager | grep -i "Type\="`
			type=${type/Type=/}
			if [[ "$type" == *"oneshot"* ]]; then
				# If the Type is oneshot we need to look at the success variable
				result=`systemctl show "$serviceName" --plain --no-pager | grep -i "Result\=" | head -n 1`
				result=${result/Result=/}
				if [[ "$result" == *"success"* ]]; then
					# This status overwrites the status assignments later on
					echook
					stateknown="true"
				fi
			fi

			# Output the sheet.
			if [ "$stateknown" != "true" ]; then
				if [[ "$state" == *"running"* ]]; then
					echook
					stateknown="true"
				fi
				if [[ "$state" == *"exit"* ]]; then
					echoexit
					stateknown="true"
				fi
				if [ "$stateknown" != "true" ]; then
					echofail
				fi
			fi

			echo "$serviceName"
		done

		if [ $(systemctl list-units --state=failed | wc -l) -gt 3 ]; then 
			echo
			systemctl list-units --state=failed
		fi

		IPS="$sIPS"
	}
fi

# Automatic zsh grml settings install
function zshSetup {
	if [ ! "$USER" == "root" ]; then
		echo "We need root to continue."
		return 1
	fi

	which zsh >/dev/null 2>&1
	if [ "$?" != "0" ]; then
		echo "Please install zsh before running this setup..."
		return 1
	fi

	if [ -z "$1" ]; then
		echo "This will (re)install the zsh configuration in 3 seconds..."
		echo "Any previously existing configuration will be deleted. CTRL+C to abort now!"
		sleep 3
	fi

	wget -O /tmp/zshrc http://git.grml.org/f/grml-etc-core/etc/zsh/zshrc
	if [ "$?" != "0" ]; then
		echo "Download problem, bailing out..."
		return 1
	fi

	rm -R /etc/zsh >/dev/null 2>&1
	mkdir /etc/zsh
	mv /tmp/zshrc /etc/zsh/
	rm /etc/skel/.zshrc /etc/skel/.zprofile >/dev/null 2>&1
	echo "source /etc/profile" >> /etc/skel/.zshrc
	cp /etc/skel/.zshrc $HOME/
	chown $USER $HOME/.zshrc >/dev/null 2>&1
	chsh -s /bin/zsh

	echo ""
	echo "zsh configuration is installed!"
}

# Automatic byobu settings install
function byobuSetup {
	if [ ! "$USER" == "root" ]; then
		echo "We need root to continue."
		return 1
	fi

	# which byobu >/dev/null 2>&1
	# if [ "$?" != "0" ]; then
	# 	echo "Please install 'byobu' before running this setup..."
	# 	return 1
	# fi

	# if [ -z "$BYOBU_BACKEND" ]; then
	# 	echo "Please launch 'byobu' before running this..."
	# 	return 1
	# fi

	byobu &

	sleep 1
	killall -9 tmux
	sleep 1

	echo 'tmux_left=" #logo #distro #release #arch session"' >> "$HOME"/.byobu/status
	echo 'tmux_right=" #network #disk_io #custom #entropy #raid reboot_required updates_available #apport #services #mail #users uptime #ec2_cost #rcs_cost #fan_speed #cpu_temp #battery #wifi_quality #processes load_average #cpu_count #cpu_freq #memory #swap #disk #whoami hostname #ip_address #time_utc date time"' >> "$HOME"/.byobu/status

	destination="$HOME/.bashrc"
	if [ "$SHELL" == "zsh" ]; then
		destination="$HOME/.zshrc"
	fi
	if [ "$1" == "forcezsh" ]; then
		destination="$HOME/.zshrc"
	fi
	echo -e '# Launch byobu on login\nif [ -z "$BYOBU_BACKEND" ]; then\nbyobu\nfi' >> "$destination"

	echo ""
	echo "All done. On your next login byobu will launch automatically. Or you can use 'byobu' now."
	echo "You can use ctrl+a-d inside of byobu to detach and drop back to a normal shell."
	echo "To get back simply relog or launch 'byobu' again!"
	return 0
}

# Automatic hachre Shell Setup
function hachreShellSetup {
	if [ ! "$USER" == "root" ]; then
		echo "We need root to continue."
		return 1
	fi

	if [ "$dyDetectedDistro" == "unknown" ]; then
		echo "Your distro is not supported for fully automatic install."
		echo "Please run zshSetup and byobuSetup on your own."
		return 1
	fi

	which zsh >/dev/null 2>&1
	if [ "$?" == "0" ]; then
		echo "Error: You should use this before installing anything."
		echo "To continue either use zshSetup manually or remove zsh and its config."
		echo "The config is /etc/zsh* and $HOME/.zsh*"
		return 1
	fi

	which byobu >/dev/null 2>&1
	if [ "$?" == "0" ]; then
		echo "Error: You should use this before installing anything."
		echo "To continue either use byobuSetup manually or remove byobu and its config."
		echo "The config is $HOME/.byobu"
		return 1
	fi

	echo "Welcome to the hachre Shell installation."
	echo "Please make sure that all instances of your current shell ($SHELL) can be killed."
	echo "If you are not ready to install, press CTRL+C now, otherwise press enter."
	read

	# Install zsh and byobu
	echo "Installing zsh and byobu..."
	dyi zsh byobu
	if [ "$?" != "0" ]; then
		echo "Error: Something bad happened during installation of 'zsh' and 'byobu'. Installation aborted."
		return 1
	fi

	# Set up zsh
	zshSetup skipIntro

	# Set up byobu
	byobuSetup forcezsh

	# Kill all current shells cause they are corrupt now anyway.
	echo "Please login again..."
	sleep 1
	killall -9 $SHELL
}

function poweroff() {
	if [ "$dyDetectedDistro" == "gentoo" ]; then
		which systemctl > /dev/null 2>&1
		if [ "$?" == "0" ]; then
			systemctl poweroff
			return 0
		fi
	fi

	location=`sh -c 'which poweroff'`
	hachreAliasesExecuteCommand "$location"
}
function reboot() {
	if [ "$dyDetectedDistro" == "gentoo" ]; then
		which systemctl > /dev/null 2>&1
		if [ "$?" == "0" ]; then
			systemctl reboot
			return 0
		fi
	fi

	location=`sh -c 'which reboot'`
	hachreAliasesExecuteCommand "$location"
}
alias halt="poweroff"

# OpenSUSE
alias zyp="zypper"

# FreeBSD
if [ "$dyDetectedDistro" == "FreeBSD" ]; then
	alias iotop="top -Smio"
fi

# macOS
alias dnsreset="sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder;"

# Various
alias pngcrush="pngcrush -rem allb -brute -reduce"
alias serve="python -m SimpleHTTPServer 8000"
function f {
	echo find . -xdev -iname "*$1*" $2 $3 $4 $5 $6 >/dev/stderr
	find . -xdev -iname "*$1*" $2 $3 $4 $5 $6 | less -rEFXKn
}

function fsize {
	if [ -z "$1" ]; then
		echo "Usage: fsize <find parameters>"
		echo "Will run the parameters through find and calculate the size of the results."
		echo "Come up with a 'find' line and once you're happy with the result, change find to fsize."
		exit 1
	fi

	find "$@" -print0 | du --files0-from=- --total -s -h | tail -1
}

# AWS
function awshelp {
	echo "AWS commands:"
	echo "awscps:    cps for S3, metadata reset, CloudFront invalidation master tool"
	echo "awsreset:  reset existing S3 metadata to dynaloop webhosting defaults (awscps shortcut)"
	echo "awscfi:    invalidate (clear) CloudFront caches (awscps shortcut)"
	echo "awscfls:   list all available CloudFront ids"
	return 1
}

function awscps {
	function show_help {
		echo "Usage: awscps [options] [-i|--invalidate or -I|--invalidate-only <cloudfrontid>] <source> <target>"
		echo "Synchronize files between a source and target, for use with S3."
		echo ""
		echo " Positional parameters:"
		echo "  source:       either a local directory or S3 bucket name"
		echo "  target:       either a local directory or S3 bucket name"
		echo ""
		echo " Named parameters:"
		echo "  -i,"
		echo "  --invalidate:       invalidates CloudFront after finish sync operation (requires <cloudfrontid>)"
		echo "                      to find the <cloudfrontid>, try 'awscfls' (aws cloudfront ls)"
		echo "  -I,"
		echo "  --invalidate-only:  same as -i|--invalidate, but no syncing operation will be attempted"
		echo ""
		echo " Options:"
		echo "  -w, --web:    assigns dynaloop webhosting defaults to S3 metadata during upload"
		echo "  -r, --reset:  resets already existing S3 metadata to dynaloop defaults (use with -w|--web)"
	}

	# http://mywiki.wooledge.org/BashFAQ/035
	# Parse the parameters
	if [ -z "$1" ]; then show_help; return; fi
	source=""
	target=""
	cloudfrontid=0
	invalidateonly=0
	reset=0
	web=0
	while :; do
		case $1 in
		-h|-\?|--help)
			show_help
			return
			;;
		-i|--invalidate)
			if [ "$2" ]; then
				cloudfrontid="$2"
				shift
			else
				show_help
				echo -e "\nError: -i|--invalidate requires a non-empty parameter 'cloudfrontid'."
				return
			fi
			;;
		-I|--invalidate-only)
			if [ "$2" ]; then
				cloudfrontid="$2"
				invalidateonly=1
				shift
			else
				show_help
				echo -e "\nError: -I|--invalidate-only requires a non-empty parameter 'cloudfrontid'."
				return
			fi
			;;
		-r|--reset)
			reset=1
			;;
		-w|--web)
			web=1
			;;
		--)
			shift
			break
			;;
		-?*)
			show_help
			echo -e "\nError: Unknown parameter: '$1'" >&2
			return
			;;
		*)
			# Whatever parameters are left and not starting with any of the above are out source and target parameters.
			source="$1"
			target="$2"
			if [ ! -z "$3" ]; then
				show_help
				echo -e "\nError: Too many positional parameters. Expected two: 'source' and 'target'."
				return
			fi
			break
		esac
	shift
	done

	function debug_parameters() {
		echo "source: $source"
		echo "target: $target"
		echo "cloudfrontid: $cloudfrontid"
		echo "reset: $reset"
		echo "web: $web"
	}
	#debug_parameters

	function sync {
		# Parameter validation
		if [ $reset == 1 ]; then
			if [ $web != 1 ]; then
				show_help
				echo -e "\nError: Giving '-r|--reset' without '-w|--web' makes no sense. Please give both if you really want to reset."
				return 1337
			fi
			if [ ! "$target" ]; then
				target="null"
			fi
		fi
		if [ ! "$source" ] || [ ! "$target" ]; then
			show_help
			if [ $reset == 1 ]; then
				echo -e "\nError: You need to define the S3 bucket name as 'source'"
				return 1337
			fi
			echo -e "\nError: Both a 'source' and 'target' value are mandatory."
			return 1337
		fi

		# Detect whether source or target is the local dir.
		if [ ! -d "$source" ] && [ ! -d "$target" ] && [ $reset != 1 ]; then
			show_help
			echo -e "\nError: Both 'source' and 'target' aren't local directories. One has to be a S3 bucket name, one has to be a local directory. Cannot proceed."
			return 1337
		fi
		s3target=0
		if [ -d "$source" ]; then
			target="s3://$target/"
			s3target="$target"
		fi

		if [ -d "$target" ]; then
			source="s3://$source/"
			s3target="$source"
		fi

		# Defaults for dynaloop web hosting metadata
		defaultOptions="--acl public-read"
		longCache="--cache-control max-age=2592000,public"
		midCache="--cache-control max-age=3720,public"
		shortCache="--cache-control max-age=600,public"

		# Command templates depending on whether -r is given or not.
		resetCmd="aws s3 cp --recursive --metadata-directive REPLACE"
		syncCmd="aws s3 sync --delete"
		cmd=""

		# Execute the commands
		if [ $reset == 1 ]; then
			echo "Resetting metadata in '$source' to dynaloop web hosting defaults..."
			cmd=${resetCmd}

			# If we have no 's3target' at this point, it means the target is 'source' but not converted to s3 yet.
			if [ "$s3target" == 0 ]; then
				s3target="s3://$source/"
			fi

			source="$s3target"
			target="$s3target"
		else
			echo "Syncing from '$source' to '$target'..."
			cmd=${syncCmd}
		fi

		${cmd} --include "*" --exclude "*.htm*" --exclude "*.js" --exclude "*.css" --exclude "*.ttf" ${defaultOptions} ${longCache} "$source" "$target"
		${cmd} --exclude "*" --include "*.ttf" --content-type "application/font" ${defaultOptions} ${longCache} "$source" "$target"
		${cmd} --exclude "*" --include "*.htm*" --content-type "text/html; charset=utf-8" ${defaultOptions} ${shortCache} "$source" "$target"
		${cmd} --exclude "*" --include "*.js" --content-type "text/javascript; charset=utf-8" ${defaultOptions} ${midCache} "$source" "$target"
		${cmd} --exclude "*" --include "*.css" --content-type "text/css; charset=utf-8" ${defaultOptions} ${midCache} "$source" "$target"
	}

	# Proceed with syncing or resetting metadata, unless a -I|--invalidate-only parameter has been given.
	if [ "$invalidateonly" != 1 ]; then
		sync

		# If we receive signal 1337 from inside the function, we need to exit.
		if [ "$?" == "1337" ]; then
			return 1
		fi
	fi

	# Invalidate CloudFront, if an id has been given.
	if [ "$cloudfrontid" != 0 ]; then
		tmpfile=$(mktemp)
		echo "Invalidating CloudFront cache for id '$cloudfrontid'..."
		aws cloudfront create-invalidation --distribution-id "$cloudfrontid" --paths /\* >"$tmpfile"
		if [ "$?" != "0" ]; then
			cat "$tmpfile"
			rm "$tmpfile"
			return 1
		fi
		rm "$tmpfile"
	fi

	# Finally done!
	echo "All done :)"
}

function awscfls {
	aws cloudfront list-distributions G id P
}

function awscfi {
	awscps -I "$1"
}

function awsreset {
	if [ -z "$1" ]; then
		echo "Usage: awsreset <s3bucketname> [cloudfrontid]"
		echo "Will reset metadata on 's3bucketname' and also invalidate CloudFront if 'cloudfrontid' was given."
		return
	fi
	if [ ! -z "$2" ]; then
		awscps -r -w -i "$2" "$1"
		return
	fi
	awscps -r -w "$1"
}

# ZFS (_ha_zl allow custom extends through zshrc_local)
alias _ha_zl="zfs list -o name,refer,used,usedsnap,avail,compressratio,mountpoint"
alias zl="_ha_zl"
alias _ha_zpl="zpool list -o name,size,alloc,free,frag,cap,dedup,health"
alias zpl="_ha_zpl"
alias _ha_zps="zpool status -D"
alias zps="_ha_zps"
function zrmsnaps {
	volume=""
	if [ -z "$1" ]; then
		echo "Usage: zrmsnaps <zfs volume> [keyword]"
		echo "Will erase all snaps under <zfs volume> recursively if they contain <keyword>."
		echo "Please note: keyword is optional. If it is ommitted, will delete ALL snapshots in volume."
		return 127
	fi
	volume="$1"

	keyword=""
	if [ ! -z "$2" ]; then
		keyword="$2"
	fi

	# Check if given volume exists
	zfs get compress "$volume" 1>/dev/null 2>&1
	if [ "$?" != "0" ]; then
		echo "Error: Given volume '$volume' doesn't exist."
		return 1
	fi

	# Prepare parameters
	keywordcmd="| grep --color=none -i $keyword"
	if [ -z "$keyword" ]; then
		keywordcmd=""
	fi

	# Execute
	function execute() {
		# Create the todo list...
		for entry in $(zfs list -t snapshot -r "$volume" -H -o name $keywordcmd); do
			if [ -z "$1" ]; then
				echo "destroying: '$entry'..."
			else
				zfs destroy -rv "$entry" 2>/dev/null
			fi
		done
	}

	# Execute in pretend mode
	execute

	echo ""
	echo "Does this look ok? Press ENTER to continue or CTRL+C to cancel..."
	read

	# Execute in actual mode
	execute --actual
}
function zfree() {
	target="$1"
	if [ -z "$target" ]; then
		# Special list mode for all zpools
		for entry in $(zpool list -o name -H); do
			zfs get -o name,value -H avail "$entry" | awk '{ print $1" "$2 }'
		done
		return
	fi
	zfs get -o value -H avail "$target"
}

function showipv6 {
	device=""
	if [ ! -z "$1" ]; then
		device="$1"
	fi
	ip -o -6 addr list scope global $device | grep -v "inet6 fc" | grep -v "inet6 fd" | grep -v "preferred_lft 0sec" | sed -n 's/.*inet6 \([0-9a-f:]\+\).*/\1/p' | head -n 1
}

# Distro Specific Changes
if [ "$dyDetectedDistro" == "FreeBSD" ]; then
	unalias dmesg
	unalias halt
	unset -f reboot
	unset -f poweroff
	unalias aria2c
	alias aria2c="aria2c -x 10 -j 10"
fi
