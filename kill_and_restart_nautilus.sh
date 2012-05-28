#!/bin/bash
# Script welches alle Nautilus Instanzen killt und dann ein
# 'nautilus -n' ausführt, sodass der Desktop wieder verwendet
# werden kann
killall nautilus 
nautilus -n
