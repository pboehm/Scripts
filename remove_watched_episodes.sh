#!/usr/bin/env bash

# Script that looks into the mediatomb db and searches
# for watched episodes and removes them

MT_DB_PATH=/var/lib/mediatomb/mediatomb.db
DB_PATH=/tmp/mediatomb_dump.db

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

sqlite3 $DB_PATH "$QUERY" | sed 's/^F//' | xargs -r -d"\n" -n1 rm

# Delete all empty directories
find -L ~/Queue/ -type d -empty | xargs -r -d"\n" rmdir
