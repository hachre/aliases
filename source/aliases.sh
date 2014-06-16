#!/bin/bash

#
# hachre's Aliases
#

# Version: 0.3.20140616.3
# Author: Harald Glatt code@hachre.de

# Default editor
EDITOR="nano"

# Shutdown Poweroff Halt Reboot
function halt() {
	if [ `whoami` != "root" ]; then
		sudo systemctl poweroff
	else
		systemctl poweroff
	fi
}
function reboot() {
	if [ `whoami` != "root" ]; then
		sudo systemctl reboot
	else
		systemctl reboot
	fi
}
function poweroff() {
	halt
}

# Bring some color into your life!
alias egrep="egrep --color=auto"
alias grep="grep --color=auto"

# Filesystem helpers
alias duhs="du -hsx * .* | sort -h"
alias da="du -hd 0"
alias cps="echo 'Usage: cps <source> <destination>'; rsync -aHh --numeric-ids --progress --delete"
alias scpi='scp -o "StrictHostKeyChecking=no" -o "UserKnownHostsFile=/dev/null"'
alias sshi='ssh -o "StrictHostKeyChecking=no" -o "UserKnownHostsFile=/dev/null"'
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

# Editor Aliases
alias nano="nano -w"
alias sublime="subl"
alias sub="subl"

# GIT commands
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

# Ubuntu Package Management Aliases
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
