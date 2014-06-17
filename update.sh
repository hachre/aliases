#!/bin/bash

# Updating hachreAliases

if [ `whoami` != "root" ]; then
   echo "Error: Update has to be run by root."
   exit 1
fi

cd /usr/local/hachre/aliases
git pull
source /etc/profile

echo "Update complete"
