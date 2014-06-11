#!/usr/bin/env bash

set -e

# Script that looks into the mediatomb db and searches
# for watched episodes and removes them

MT_DB_PATH=/var/lib/mediatomb/mediatomb.db
DB_PATH=/tmp/mediatomb_dump.db
KEEP_SERIES_PATH=/home/pi/.keep_series
SERIES_DIR=/home/pi/Serien/

QUERY=$(cat <<'END_HEREDOC'
SELECT
    (SELECT location
    FROM mt_cds_object
    WHERE id = m.ref_id) as episode_path
FROM mt_cds_object m
WHERE ref_id is not null
    AND episode_path LIKE "%/pi/Queue/%"
    AND flags != 1
ORDER BY episode_path;
END_HEREDOC
)

cp $MT_DB_PATH $DB_PATH
IFS=$'\n'

for file in `sqlite3 $DB_PATH "$QUERY" | sed 's/^F//'`
do
    echo $file

    series=$(basename `dirname "$file"`)
    if [[ -n `grep "$series" $KEEP_SERIES_PATH` ]]; then
        filename=`basename "$file"`
        id=`echo "$filename" | cut -dE -f1 | cut -dS -f2`
        path="$SERIES_DIR$series/Staffel $id/"

        mkdir -p "$path"
        mv "$file" "$path"

    else
        rm "$file"
    fi
done

# # Delete all empty directories
find -L ~/Queue/ -type d -empty | xargs -r -d"\n" rmdir
