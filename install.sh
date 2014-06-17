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

if [ -e "/etc/profile.d/hachreAliases.sh" ]; then
   rm "/etc/profile.d/hachreAliases.sh" >/dev/null 2>&1
fi

ln -s /usr/local/hachre/aliases/source/aliases.sh /etc/profile.d/hachreAliases.sh

if [ "$?" != "0" ]; then
   echo "Installation failed :("
   exit 1
fi

echo "Installation succeeded!"
echo "Do 'source /etc/profile' followed by 'hachreAliases' to verify installation."
