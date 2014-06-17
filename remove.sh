#!/bin/bash

# Uninstall script

if [ `whoami` != "root" ]; then
   echo "Error: Removal has to be run by root."
   exit 1
fi

echo "Removing hachreAliases..."

rm /etc/profile.d/hachreAliases.sh >/dev/null 2>&1
rm -Rf /usr/local/hachre/aliases >/dev/null 2>&1
rmdir /usr/local/hachre >/dev/null 2>&1

echo "Removal complete."
echo "Relog into your shells to make the existing aliases disappear."
