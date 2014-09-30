#!/usr/bin/python
# This script guesses the series name of the supplied episode file
# and prints them to stdout each series name on a separate line

import json
import sys
import os.path
import time
from datetime import datetime

try:
    EPISODE_FILE, EPISODE_ID = sys.argv[1], sys.argv[2]
except Exception:
    print "You have to pass an episode file and the episode id (1_1) as params"
    sys.exit(1)

DUMP_FILE = "/home/pi/.series/episode_dump.json"
DUMP_FILE_CONTENT = json.loads(open(DUMP_FILE, "r").read())

created = datetime.strptime(
            time.ctime(os.path.getctime(EPISODE_FILE)), "%a %b %d %H:%M:%S %Y")

last_episode = None

for episode in reversed(DUMP_FILE_CONTENT):
    episode_dumped = datetime.strptime(
                        episode['extracted_at'].split("+")[0], # remove the millisecond portion
                        '%Y-%m-%dT%H:%M:%S')

    if episode_dumped < created:
        break

    if episode['id'] == EPISODE_ID:
        last_episode = episode

if last_episode:
    print last_episode['series']
