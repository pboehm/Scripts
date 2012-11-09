#!/usr/bin/env bash

# Script that looks into the mediatomb db and searches
# for watched episodes and removes them

MT_DB_PATH=/etc/mediatomb/mediatomb.db
DB_PATH=/tmp/mediatomb_dump.db

cp $MT_DB_PATH $DB_PATH

sql='SELECT * FROM mt_cds_object WHERE location LIKE "%/home/philipp/Downloads/.%" AND upnp_class = "object.item.videoItem" AND flags != 1;'
sqlite3 -line $DB_PATH "$sql" | grep "location =" | cut -d= -f2 | sed 's/^ F//' | xargs -r -d"\n" trash-put

# Delete all empty directories
find -L ~/Downloads/.{noch,weiter}* -type d -empty | xargs -r -d"\n" rmdir
