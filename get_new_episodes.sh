#!/usr/bin/env bash

# Script that runs getserieslinks holds it output, starts the jDownloader
# and detaches from the current shell
#
# Autor: Philipp Böhm

GSL_PATH=~/projects/getserieslinks/getserieslinks.pl
GSL_LINKS_PATH=/tmp/gsl_links.txt
JD_PATH=~/.jd/JDownloader.jar

$GSL_PATH --nodecrypt $@

if [[ -z `cat $GSL_LINKS_PATH` ]]; then
    exit 0
fi

LINKS=`cat $GSL_LINKS_PATH | tr "\n" " "`

java -jar $JD_PATH --add-links $LINKS 2> /dev/null > /dev/null &
disown

rm $GSL_LINKS_PATH
