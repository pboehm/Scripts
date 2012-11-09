#!/usr/bin/env bash

# Script that make some pre/post processing for the 
# seriesindex. The index is versioned by git

SINDEX_DIRECTORY=~/.sindex/index/

cd $SINDEX_DIRECTORY

if [[ $1 == "pre" ]]; then
    git pull
fi

if [[ $1 == "post" ]]; then
    git add seriesindex.xml && git commit -m "Sindex: Post-Processing Commit" && git push
fi
