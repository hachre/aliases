#!/bin/bash

# Publishing Helper Script

nano version.txt
version=`cat version.txt | head -n 1`
linenr=`cat -n source/aliases.sh | grep "Version:" | head -n 1 | awk '{ print $1 }'`
sed "${linenr}s/.*/# Version: ${version}/g" source/aliases.sh > aliases-new.sh
mv aliases-new.sh source/aliases.sh
source source/aliases.sh
gitit
