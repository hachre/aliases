#!/bin/bash

# Publishing Helper Script

$EDITOR version.txt
version=`cat version.txt | head -n 1`
linenr=`cat -n source/aliases.sh | grep "hachreAliasesVersion" | head -n 1 | awk '{ print $1 }'`
sed "${linenr}s/.*/hachreAliasesVersion=${version}/g" source/aliases.sh > aliases-new.sh
mv aliases-new.sh source/aliases.sh
source ~/.local/hachre/aliases/source/aliases.sh 2>/dev/null
source /usr/local/hachre/aliases/source/aliases.sh 2>/dev/null
gitit
