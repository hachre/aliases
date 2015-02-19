#!/bin/bash

# Updating hachreAliases

dir="unknown"

if [ -d "$HOME/.local/hachre/aliases" ]; then
	dir="$HOME/.local/hachre/aliases"
fi

if [ "$dir" == "unknown" ]; then
	if [ `whoami` != "root" ]; then
		echo "Error: hachreupdate has to be run by root."
		exit 1
	fi
		
	if [ -d "/usr/local/hachre/aliases" ]; then
		dir="/usr/local/hachre/aliases"		
	fi
fi

prev=`pwd`
cd "$dir"

set -e

git fetch -f
echo "Updated from:"
git reset --hard
git pull origin master
git checkout master
echo "Updated to:"
git reset --hard

cd "$prev"

echo ""
echo "Update complete"
echo "Do 'source /etc/profile' followed by 'hachreAliases' to verify."
