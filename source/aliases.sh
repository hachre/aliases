#!/bin/bash

# hachre's Aliases
# Author: Harald Glatt code@hachre.de
# URL: https://github.com/hachre/aliases
# Version:
hachreAliasesVersion=0.11.20140616.12

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
if [ "$?" == "0" ]; then
	hachreAliasesSystemctl="systemctl"
fi

function halt() {
	$hachreAliasesRoot $hachreAliasesSystemctl poweroff
}
function reboot() {
	$hachreAliasesRoot $hachreAliasesSystemctl reboot
}
alias poweroff="halt"

#
# Color Settings
#

alias egrep="egrep --color=auto"
alias grep="grep --color=auto"

#
# Filesystem Helpers
#

alias duhs="du -hsx * .* | sort -h"
alias dfh="df -h"
alias da="du -hd 0"
alias cps="echo 'Usage: cps <source> <destination>'; rsync -aHh --numeric-ids --progress --delete"
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
function gitit() {
	commit="dev"
	if [ -e "version.txt" ]; then
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
	alias pmcc="$root $hachreAliasesArchPM -Scc; $root rm -Rf /var/cache/pkgfile/* >/dev/null 2>&1; $root rm -Rf /var/abs/* >/dev/null 2>&1"
	alias pmi="$root $hachreAliasesArchPM -Suy"
	alias pmii="$root $hachreAliasesArchPM -S"
	alias pmin="$root $hachreAliasesArchPM -S --needed"
	alias pmif="$root $hachreAliasesArchPM -U"
	alias pmie="$root $hachreAliasesArchPM -Suy --asexplicit"
	alias pmid="$root $hachreAliasesArchPM -Suy --asdeps"
	alias pmq="$root $hachreAliasesArchPM -Q"
	alias pmqq="$root $hachreAliasesArchPM -Qq"
	alias pmqi="$root $hachreAliasesArchPM -Qi"
	alias pmqe="$root $hachreAliasesArchPM -Q --explicit"
	alias pmqd="$root $hachreAliasesArchPM -Q --deps"
	alias pmql="$root $hachreAliasesArchPM -Ql"
	alias pmqm="$root $hachreAliasesArchPM -Qm"
	alias pmme="$root $hachreAliasesArchPM -D --asexplicit"
	alias pmmd="$root $hachreAliasesArchPM -D --asdeps"
	alias pmr="$root $hachreAliasesArchPM -Rc"
	alias pmdepclean="$root $hachreAliasesArchPM -Qdtq | $root $hachreAliasesArchPM -Rs -"
	alias pmdc="pmdepclean"
	alias pmar="pmdepclean"
	alias pmrs="$root $hachreAliasesArchPM -Rcs"
	alias pmrss="$root $hachreAliasesArchPM -Rcss"
	alias pms="$root $hachreAliasesArchPM -Ss"
	alias pmsi="$root $hachreAliasesArchPM -Si"
	alias pmowns="$root $hachreAliasesArchPM -Qo"
	alias pmprovides="$root pkgfile"
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
