#!/bin/bash

# hachre's Aliases
# Author: Harald Glatt code@hachre.de
# URL: https://github.com/hachre/aliases
# Version:
hachreAliasesVersion=0.35.20141214.2

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
# Various
#

alias flushdns="dscacheutil -flushcache"
function psall() {
	if [ -z "$1" ]; then
		ps aux | grep -v '\[' | grep -v '\]'
	else
		ps aux | grep -v '\[' | grep -v '\]' | grep -i "$1" | grep -v "grep"
	fi
}
alias lsnet="ls /sys/class/net"
function checkheader() {
	curl "$1" -s -D /tmp/header 1>/dev/null
	cat /tmp/header
	rm /tmp/header
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
	alias pmowns="$root $hachreAliasesArchPM -Qo"
	alias pmqo="pmowns"
	alias pmprovides="$root pkgfile"
	alias pmlast="$hachreAliasesRoot paclog-pkglist /var/log/pacman.log | cut -d ' ' -f 1"
	function hachreAliasesaursh() {
	   d=${BUILDDIR:-$PWD}
	   for p in ${@##-*}
	   do
	   cd $d
	   $hachreAliasesRoot curl https://aur.archlinux.org/packages/${p:0:2}/$p/$p.tar.gz |tar xz
	   cd $p
	   $hachreAliasesRoot makepkg -si --asroot --needed --noconfirm --skippgpcheck ${@##[^\-]*}
	   done
	}
	function pmsetup() {
		echo "Proceeding to set up hachre Arch Build system..."
		$hachreAliasesRoot groupadd -g 500 archbuild
		$hachreAliasesRoot useradd -u 500 -g 500 -d /dev/null archbuild
		$root $hachreAliasesArchPM -S --needed --noconfirm sudo curl binutils base base-devel
		$hachreAliasesRoot echo "archbuild ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
		mytemp=`$hachreAliasesRoot mktemp`
		$hachreAliasesRoot rm "$mytemp"
		$hachreAliasesRoot mkdir -p "$mytemp"
		cd "$mytemp"
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
}
