#!/usr/bin/env bash

# Script that processes episodes that are copied by
# the serienmover tool and moves them to the ".nochzuschauen"
# directory.
# It expects two Parameters:
#   1. path to episodefile
#   2. episodename
#
# author: Philipp Böhm

NOCHZUSCHAUEN=~/Downloads/.nochzuschauen/

episodefile=$1
seriesname=$2

target=$NOCHZUSCHAUEN

if [[ -n $seriesname ]]; then
    target="$target$seriesname/"
fi

mkdir -p "$target"

mv "$episodefile" "$target"
