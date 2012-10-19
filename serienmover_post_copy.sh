#!/usr/bin/env bash

# Script that processes episodes that are copied by
# the serienmover tool and moves them to the ".nochzuschauen"
# directory.
# It expects two Parameters:
#   1. path to episodefile
#   2. episodename
#
# author: Philipp Böhm

WEITERSCHAUEN=~/Downloads/.weiterschauen/
NOCHZUSCHAUEN=~/Downloads/.nochzuschauen/
HISTORY_FILE=~/.local/share/recently-used.xbel

episodefile=$1
[[ ! -f $episodefile ]] && echo "file '$episodefile' not exists" && exit

encoded_episode=$(python -c "import urllib; print urllib.quote('''$episodefile''')")

seriesname=$2

###
# check if this epsiode was already played and could be removed
if [[ -f $HISTORY_FILE ]]; then
    if [[  -n `egrep "$episodefile" $HISTORY_FILE` || -n `egrep "$encoded_episode" $HISTORY_FILE` ]]
    then
        echo "episode was already played, I move this to the trash folder"
        trash-put "$episodefile"
        exit
    fi
fi

###
# build up the targetdir and moves this into this dir
target="$WEITERSCHAUEN$seriesname/"

if [[ ! -d $target ]]; then
    target="$NOCHZUSCHAUEN$seriesname/"
    mkdir -p "$target"
fi

mv "$episodefile" "$target"
