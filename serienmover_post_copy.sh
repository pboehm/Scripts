#!/usr/bin/env bash

# Script that processes episodes that are copied by
# the serienmover tool and moves them to the ".nochzuschauen"
# directory.
# It expects two Parameters:
#   1. path to episodefile
#   2. episodename
#
# author: Philipp Böhm

NOCHZUSCHAUEN=~/Queue/

episodefile=$1
[[ ! -f $episodefile ]] && echo "file '$episodefile' not exists" && exit

seriesname=$2

###
# build up the targetdir and moves this into this dir
target="$NOCHZUSCHAUEN$seriesname/"
mkdir -p "$target"

mv "$episodefile" "$target"
