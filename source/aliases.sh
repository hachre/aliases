#!/bin/bash

# hachre's Aliases
# Author: Harald Glatt code@hachre.de
# URL: https://github.com/hachre/aliases
# Version:
hachreAliasesVersion=0.64.20150222.5

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
hachreAliasesRoot=""
if [ `whoami` != "root" ]; then
	which sudo >/dev/null 2>&1
	if [ "$?" == "0" ]; then
		hachreAliasesRoot="sudo"
	fi
fi

#
### Settings
#

# Set the default editor
EDITOR="nano"

#
### Aliases
#

#
# Shutdown Poweroff Halt Reboot ###
#

hachreAliasesSystemctl=""
which systemctl >/dev/null 2>&1
#if [ "$?" == "0" ]; then
#	hachreAliasesSystemctl="systemctl"
#fi

function hachreAliasesExecuteCommand() {
	hachreAliasesCommand="$1"
	$hachreAliasesRoot $hachreAliasesSystemctl $hachreAliasesCommand
}
function poweroff() {
	location=`sh -c 'which poweroff'`
	hachreAliasesExecuteCommand "$location"
}
function reboot() {
	location=`sh -c 'which reboot'`
	hachreAliasesExecuteCommand "$location"
}
alias halt="poweroff"

# zsh only aliases

if [ "$SHELL" == "zsh" ]; then
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

#
# Color Settings
#

alias egrep="egrep --color=always"
alias grep="grep --color=always"

#
# Filesystem Helpers
#

alias duhs="du -hsx * .* --exclude "proc" | sort -h"
alias dfh="df -h"
alias da="du -hd 0"
alias cps="rsync -aHhP --numeric-ids --delete"
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
function checkssl() {
	if [ -z "$1" ]; then
		echo "Usage: checkssl hostname"
		return 1
	fi
	openssl s_client -connect $1:443 -nextprotoneg ''
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

#
# SSH
#

alias scpi='scp -o "StrictHostKeyChecking=no" -o "UserKnownHostsFile=/dev/null"'
alias sshi='ssh -o "StrictHostKeyChecking=no" -o "UserKnownHostsFile=/dev/null"'

#
# Editors
#

alias nano="nano -w"
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
		nano "version.txt"
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

#
# Ubuntu / Debian Package Management
#

which apt-get >/dev/null 2>&1
if [ "$?" == "0" ]; then
	alias aga="sudo apt-get autoremove"
	alias agar="sudo apt-get autoremove"
	alias agr="sudo apt-get remove"
	alias agi="sudo apt-get install"
	alias au="sudo apt-get update"
	alias adg="sudo apt-get dist-upgrade"
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
	alias pm="$root $hachreAliasesArchPM"
	alias pmc="$root $hachreAliasesArchPM -Sc"
	alias pmi="$root $hachreAliasesArchPM -Suy --needed"
	function pmif() {
		$root $hachreAliasesArchPM -Suy --needed $(pacman -Ssq "$@")
	}
	alias pmii="$root $hachreAliasesArchPM -S"
	alias pmin="$root $hachreAliasesArchPM -S --needed"
	alias pmif="$root $hachreAliasesArchPM -U"
	alias pmie="$root $hachreAliasesArchPM -Suy --asexplicit"
	alias pmid="$root $hachreAliasesArchPM -Suy --asdeps"
	alias pmq="$root $hachreAliasesArchPM -Q"
	alias pmqs="$hachreAliasesRoot pacsysclean"
	alias pmsize="pmqs"
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
	alias pmr="$root $hachreAliasesArchPM -Rc"
	function pmrf() {
		$root $hachreAliasesArchPM -Rcs $(pacman -Qqs "$@")
	}
	alias pmdepclean="$root $hachreAliasesArchPM -Qdtq | $root $hachreAliasesArchPM -Rs -"
	alias pmdc="pmdepclean"
	alias pmar="pmdepclean"
	alias pmrs="$root $hachreAliasesArchPM -Rcs"
	alias pmrss="$root $hachreAliasesArchPM -Rcss"
	alias pms="$root $hachreAliasesArchPM -Ss"
	alias pmsi="$root $hachreAliasesArchPM -Si"
	alias pmsg="$root $hachreAliasesArchPM -Sgq"
	alias pmowns="$root $hachreAliasesArchPM -Qo"
	alias pmqo="pmowns"
	alias pmprovides="$root pkgfile"
	alias pmkeys="pacman-key --refresh-keys"
	alias pmlast="$hachreAliasesRoot paclog-pkglist /var/log/pacman.log | cut -d ' ' -f 1"
	function hachreAliasesaursh() {
	   d=${BUILDDIR:-$PWD}
		for p in ${@##-*}; do
		   cd $d
		   $root curl https://aur.archlinux.org/packages/${p:0:2}/$p/$p.tar.gz | $root tar xz
		   cd $p
		   $root makepkg -si --needed --noconfirm --skippgpcheck ${@##[^\-]*}
	   done
	}
	function pmsetup() {
		echo "Proceeding to set up hachre Arch Build system..."
		$hachreAliasesRoot userdel -rf archbuild >/dev/null 2>&1
		$hachreAliasesRoot groupdel archbuild >/dev/null 2>&1
		$hachreAliasesRoot groupadd -g 500 archbuild
		$hachreAliasesRoot useradd -u 500 -g 500 -m archbuild
		$root gpg --list-keys
		$root echo "keyring /etc/pacman.d/gnupg/pubring.gpg" >> /home/archbuild/.gnupg/gpg.conf
		$root $hachreAliasesArchPM -S --needed --noconfirm sudo curl binutils base base-devel
		$root $hachreAliasesArchPM -R --noconfirm pacaur cower 2>/dev/null
		$hachreAliasesRoot echo "archbuild ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
		mytemp=`$hachreAliasesRoot mktemp`
		$hachreAliasesRoot rm "$mytemp"
		$hachreAliasesRoot mkdir -p "$mytemp"
		$hachreAliasesRoot chown -R archbuild "$mytemp"
		cd "$mytemp"
		echo "$mytemp"
		hachreAliasesaursh cower
		hachreAliasesaursh pacaur
		cd /
		$hachreAliasesRoot rm -Rf "$mytemp"
		echo "Everything should be set up!"
	}

	function hachreAliasesCleanLogs() {
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
	alias logclean="hachreAliasesCleanLogs"
	alias baseclean="echo 'Baseclean cleans a lot of stuff... You may CTRL+C!'; $root $hachreAliasesArchPM -Scc && sudo rm -Rf /var/cache/pkgfile/* >/dev/null 2>&1 && sudo rm -Rf /var/abs/* >/dev/null 2>&1 && sudo rm -Rf /var/cache/lxc/* >/dev/null 2>&1 && hachreAliasesCleanLogs"
}

which pacman >/dev/null 2>&1
if [ "$?" == "0" ]; then
	hachreAliasesArchPM="pacman"

	which pacaur >/dev/null 2>&1
	if [ "$?" == "0" ]; then
		root="sudo -u archbuild -s"
		hachreAliasesArchPM="pacaur --noedit"
	fi

	setupArchAliases
fi

#
# Systemctl
#

which systemctl >/dev/null 2>&1
if [ "$?" == "0" ]; then
	alias start="systemctl start"
	alias stop="systemctl stop"
	alias restart="systemctl restart"
	alias reload="systemctl reload"
	alias status="systemctl status"
	alias sstatus="systemctl --type=service --no-pager | grep -v systemd"
	function viewlog {
		# Views Journalctl log in Less
		if [ -z "$1" ]; then
			echo "Usage: viewlog <unit name> [... optional parameters for journalctl ...]"
			echo "See also: followlog"
			return 1
		fi
		journalctl --since today --no-pager -u "$@" | less +F
	}
	function followlog {
		# Follow JournalCtl log in realtime
		if [ -z "$1" ]; then
			echo "Usage: followlog <unit name> [... optional parameters for journalctl ...]"
			echo "See also: viewlog"
			return 1
		fi
		journalctl -n 500 -f -u "$@"
	}
	function sfind {
		if [ -z "$1" ]; then
			echo "Usage: sfind <pattern>"
			return 1
		fi

		searchstring=""
		for word in "$@"; do
			searchstring="${searchstring}*${word}*"
		done

		# Remove double *
		searchstring=`echo $searchstring | sed "s/\*\*/\*/g"`

		find /lib/systemd -iname $searchstring
	}
	function sdisable {
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
		systemctl disable "$1"
		systemctl reset-failed "$1" >/dev/null 2>&1
		systemctl disable "$1" >/dev/null 2>&1
	}
	function senable() {
		systemctl reset-failed "$1" >/dev/null 2>&1
		systemctl enable -f "$1"
		systemctl reenable "$1" >/dev/null 2>&1
	}
fi

#
# hachreProjects
#
function packageProjects() {
	# package hachreProjects (tm)

	# Configuration
	destdir="$HOME/Dropbox/Backups/Code/Backups"
	destdir2="$HOME/MEGA/Backups/Code/Backups"

	# We assume to be in a project root directory.
	# Traverse subfolders and search for version.txt files.
	for project in `find * -depth 0 -type d -print`; do
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

		echo "  -> Package created."
	done

	echo "Moving created packages into Dropbox..."
	mv *xz "$destdir" > /dev/null 2>&1
	if [ "$destdir2" != "" ]; then
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
	which equo 1>/dev/null 2>/dev/null
	if [ "$?" == "0" ]; then
		dyDetectedDistro="sabayon"
		dyDistroInfo="\n * The native package manager for this distro is called 'equo'.\n * You might also need to use 'emerge' in advanced circumstances.\n * Searching is best done via 'eix'."
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
	which emerge 1>/dev/null 2>&1
	if [ "$?" == "0" ]; then
		dyDetectedDistro="gentoo"
		dyDistroInfo="\n * The native package manager for this distro is called 'emerge'.\n * You might also wanna look at 'equery'\n * Searching is best done via 'eix'."
		return 0
	fi

	# OS X with Brew
	if [ -f "/usr/local/bin/brew" ]; then
		dyDetectedDistro="osx-brew"
		dyDistroInfo="\n * The native package manager is 'brew'."
		return 0
	fi

	# Not found
	dyDetectedDistro="unknown"
	return 1
}
dyDetectDistro

# hachre's unified packaging commands
function dyh {
	if [ "$dyDetectedDistro" == "unknown" ]; then
		echo "Error: Sadly, your distro is not supported."
		return 1
	fi

	echo "dynaloop unified package managing commands"
	echo ""

	echo "Your distro is supported and has been detected as '$dyDetectedDistro'."
	if [ ! -z "${dyDistroInfo}" ]; then
		echo -e "${dyDistroInfo}"
	fi

	echo ""
	echo "List of unified package management commands:"
	echo -e " dyi\tInstall a package from the primary repo (after confirmation)"
	echo -e " dyif\tInstall a package forced from the primary repo (after confirmation)"
	echo -e " dyii\tInstall a package from the secondary repo (after confirmation)"
	echo -e " dyr\tRemove a package (after confirmation, including its unused dependencies)"
	echo -e " dyrf\tRemove a package forced (after confirmation, including its unused dependencies)"
	echo -e " dyu\tDo a full system upgrade (primary repo, without first syncing)"
	echo -e " dyuu\tDo a full system upgrade (secondary repo, without first syncing)"
	echo -e " dyv\tVerify system sanity"
	echo -e " dyx\tSync the primary repository"
	echo -e " dyxx\tSync the secondary repository"
	echo -e " dys\tSearch a package (in the main repo)"
	echo -e " dyss\tSearch a package (in the extended repo)"
	return 0
}
function dyx {
	if [ "$dyDetectedDistro" == "sabayon" ]; then
		equo update

		eix-update >/dev/null 2>&1 &
		echo ""
		echo "Syncing is done, but the searcher database is still syncing in the background... (psall eix)"
	fi

	if [ "$dyDetectedDistro" == "gentoo" ]; then
		echo "Syncing..."
		which emerge-webrsync >/dev/null 2>&1
		if [ "$?" == "0" ]; then
			emerge-webrsync -q
		fi
		emerge --sync

		eix-update >/dev/null 2>&1 &
		echo ""
		echo "Syncing is done, but the searcher database is still syncing in the background... (psall eix)"
	fi

	if [ "$dyDetectedDistro" == "osx-brew" ]; then
		brew update
	fi
}

function dyxx {
	if [ "$dyDetectedDistro" == "sabayon" ]; then
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
	fi

	if [ "$dyDetectedDistro" == "gentoo" ]; then
		layman -S

		eix-remote update >/dev/null 2>&1 &
		echo ""
		echo "Syncing is done, but the searcher database is still syncing in the background... (psall eix)"
	fi

	if [ "$dyDetectedDistro" == "osx-brew" ]; then
		echo "Info: This command is not supported on 'osx-brew', because there is no secondary repo."
		return 1
	fi
}

function dyv {
	if [ "$dyDetectedDistro" == "sabayon" ]; then
		equo deptest
		equo libtest
		equo conf update
	fi

	if [ "$dyDetectedDistro" == "gentoo" ]; then
		echo "Not implemented yet."
		return 1
	fi

	if [ "$dyDetectedDistro" == "osx-brew" ]; then
		brew doctor
	fi
}

function dyu {
	if [ "$dyDetectedDistro" == "sabayon" ]; then
		equo upgrade -av  $*
		if [ "$?" != "0" ]; then
			return 1
		fi
		equo conf update
	fi

	if [ "$dyDetectedDistro" == "gentoo" ]; then
		emerge -uD -kk --newuse --with-bdeps=y --binpkg-respect-use=y @world -avt
		if [ "$?" == "0" ]; then
			emerge --depclean -avt
			etc-update
		fi
	fi

	if [ "$dyDetectedDistro" == "osx-brew" ]; then
		brew upgrade
	fi
}

function dyuu {
	if [ "$dyDetectedDistro" == "sabayon" ]; then
		echo "Info: Automated secondary repo upgrading is not supported on this platform."
		echo ""
		echo "Instruction for manual update are as follows:"
		echo " 1. Look at /etc/entropy/packages/package.mask"
		echo " 2. Run each of those packages against emerge -pv <packagename>"
		echo " 3. Use dyii on the packages that are outdated to update them."
		return 1
	fi

	if [ "$dyDetectedDistro" == "gentoo" ]; then
		echo "Info: dyuu and dyu are equal on this platform."
		dyu $*
	fi

	if [ "$dyDetectedDistro" == "osx-brew" ]; then
		echo "Info: This command is not supported on 'osx-brew', because there is no secondary repo."
		return 1
	fi
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
	fi

	if [ "$dyDetectedDistro" == "gentoo" ]; then
		emerge -atvkk --quiet-build=y --binpkg-respect-use=y $*
	fi

	if [ "$dyDetectedDistro" == "osx-brew" ]; then
		if [ ! -z "$2" ]; then
			echo "Error: 'osx-brew' supports only one package parameter."
			return 1
		fi
		brew install "$1"
	fi
}
function dyif {
	if [ -z "$1" ]; then
		echo "Usage: dyif <package name>"
		return 1
	fi

	if [ "$dyDetectedDistro" == "sabayon" ]; then
		equo unmask $* 1>/dev/null 2>&1
		dyi -av $*
	fi

	if [ "$dyDetectedDistro" == "gentoo" ]; then
		dyi --usepkg=n $*
	fi

	if [ "$dyDetectedDistro" == "osx-brew" ]; then
		dyi $*
	fi
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
	fi

	if [ "$dyDetectedDistro" == "gentoo" ]; then
		echo "Info: dyii and dyi are equal on this platform."
		dyi $*
	fi

	if [ "$dyDetectedDistro" == "osx-brew" ]; then
		echo "Info: This command is not supported on 'osx-brew', because there is no secondary repo."
		return 1
	fi
}
function dyr {
	if [ -z "$1" ]; then
		echo "Usage: dyr <package name>"
		return 1
	fi

	if [ "$dyDetectedDistro" == "sabayon" ]; then
		equo remove --deep -av $*
		equo unmask $* 1>/dev/null 2>/dev/null
	fi

	if [ "$dyDetectedDistro" == "gentoo" ]; then
		emerge --depclean -tav $*
	fi

	if [ "$dyDetectedDistro" == "osx-brew" ]; then
		if [ ! -z "$2" ]; then
			echo "Error: 'osx-brew' supports only one package parameter."
			return 1
		fi
		brew uninstall "$1"
	fi
}
function dyrf {
	if [ -z "$1" ]; then
		echo "Usage: dyrf <package name>"
		return 1
	fi

	if [ "$dyDetectedDistro" == "sabayon" ]; then
		dyr --force-system $*
	fi

	if [ "$dyDetectedDistro" == "gentoo" ]; then
		emerge --unmerge -tav $*
	fi

	if [ "$dyDetectedDistro" == "osx-brew" ]; then
		if [ ! -z "$2" ]; then
			echo "Error: 'osx-brew' supports only one package parameter."
			return 1
		fi
		brew uninstall --force "$1"
	fi
}
function dys {
	if [ -z "$1" ]; then
		echo "Usage: dys <package name>"
		return 1
	fi

	if [ "$dyDetectedDistro" == "sabayon" ] || [ "$dyDetectedDistro" == "gentoo" ]; then
		which eix > /dev/null 2>&1
		if [ "$?" != "0" ]; then
			# Install eix
			dyi eix

			# Upgrade eix cache
			eixupdate
		fi
		eix -F $* | less -rEFXKn
	fi

	if [ "$dyDetectedDistro" == "osx-brew" ]; then
		brew search $*
	fi
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
	fi

	if [ "$dyDetectedDistro" == "osx-brew" ]; then
		echo "Info: This command is not supported on 'osx-brew', because there is no secondary repo."
		return 1
	fi
}

# Gentoo openrc specific init helpers
which systemctl >/dev/null 2>&1
if [ "$?" != "0" ]; then
	if [ "$dyDetectedDistro" == "gentoo" ]; then
		function start {
			if [ -z "$1" ]; then
				echo "Usage: start <service>"
				return 1
			fi

			/etc/init.d/"$1" start
		}

		function stop {
			if [ -z "$1" ]; then
				echo "Usage: stop <service>"
				return 1
			fi

			/etc/init.d/"$1" stop
		}

		function restart {
			if [ -z "$1" ]; then
				echo "Usage: restart <service>"
				return 1
			fi

			/etc/init.d/"$1" restart
		}

		function reload {
			if [ -z "$1" ]; then
				echo "Usage: reload <service>"
				return 1
			fi

			/etc/init.d/"$1" reload
		}

		function status {
			if [ -z "$1" ]; then
				echo "Usage: status <service>"
				return 1
			fi

			/etc/init.d/"$1" status
		}

		function senable {
			if [ -z "$1" ]; then
				echo "Usage: senable [service] (runlevel)"
				return 1
			fi

			runlevel="default"
			if [ ! -z "$2" ]; then
				runlevel="$2"
			fi

			rc-update add "$1" default
		}

		function sdisable {
			if [ -z "$1" ]; then
				echo "Usage: sdisable [service] (runlevel)"
				return 1
			fi

			runlevel="default"
			if [ ! -z "$2" ]; then
				runlevel="$2"
			fi

			rc-update del "$1" default
		}

		function sstatus {
			rc-status
		}

		function sfind {
			cd /etc/init.d/

			if [ -z "$1" ]; then
				find . -type f
				return 0
			fi

			find . -type f -iname "*$1*"
			return 0
		}
	fi
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

	echo "This will (re)install the zsh configuration in 3 seconds..."
	echo "Any previously existing configuration will be deleted. CTRL+C to abort now!"
	sleep 3

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

	mkdir "$HOME/.byobu" >/dev/null 2>&1
	echo 'tmux_left=" #logo #distro #release #arch session"' >> "$HOME"/.byobu/status
	echo 'tmux_right=" #network #disk_io #custom #entropy #raid reboot_required updates_available #apport #services #mail #users uptime #ec2_cost #rcs_cost #fan_speed #cpu_temp #battery #wifi_quality #processes load_average #cpu_count #cpu_freq #memory #swap #disk #whoami hostname #ip_address #time_utc date time"' >> "$HOME"/.byobu/status

	destination="$HOME/.bashrc"
	if [ "$SHELL" == "zsh" ]; then
		destination="$HOME/.zshrc"
	fi
	if [ "$1" == "forcezsh" ]; then
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

	# Install zsh and byobu
	dyi zsh byobu
	if [ "$?" != "0" ]; then
		echo "Error: Something bad happened during installation of 'zsh' and 'byobu'. Installation aborted."
		return 1
	fi

	# Set up zsh
	zshSetup

	# Set up byobu
	byobuSetup forcezsh

	# Print you can close this message for old terminal
	echo "Installation finished. You can close this terminal."

	# Launch zsh & byobu
	zsh -c "byobu"
}
