#!/bin/bash

# Basic Installation Script

if [ `whoami` != "root" ]; then
   echo "Error: Installation has to be run by root."
   exit 1
fi

which git >/dev/null 2>&1
if [ "$?" != "0" ]; then
   echo "Error: We need 'git' to be installed."
   exit 1
fi

echo "Installing hachreAliases"

mkdir -p /usr/local/hachre/
cd /usr/local/hachre
git clone https://github.com/hachre/aliases.git
chmod a+x aliases/*sh

if [ "$?" != "0" ]; then
   echo "Installation failed :("
   exit 1
fi

echo "Installation succeeded!"
echo "You can now add 'source /usr/local/hachre/aliases/source/aliases.sh' to your bashrc."