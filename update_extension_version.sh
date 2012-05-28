#!/bin/bash
#
# Script, welches die Gnome-Shell-Version in den Erweiterungen auf
# die aktuell installierte Version updatet. 
#
# Autor: Philipp Böhm
# URL: http://www.tuxorials.de
# Lizenz: GNU General Public License v2
# Lizenztext: http://www.gnu.org/licenses
# 
VERSION=`gnome-shell --version | cut -d " " -f3`

cd /home/philipp/.local/share/gnome-shell/extensions

for file in `find -L .  -name metadata.json`
do
    sed -i " s/.*shell-version.*/ \"shell-version\": [ \"$VERSION\" ],/ " $file
done 
