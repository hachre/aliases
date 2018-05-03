#!/bin/sh

for tty in `w -hs | awk '$3 == "mosh" {print $2}'`; do pkill -9 -t $tty; done
for tty in `w -hs | awk '$3 == "tmux" {print $2}'`; do pkill -9 -t $tty; done