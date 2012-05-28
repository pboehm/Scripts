#!/bin/bash

#
# Script welches von einer CD/DVD ein iso-Image erstellt
#
# Autor: Philipp Böhm
# URL: http://www.tuxorials.de
# Lizenz: GNU General Public License v2
# Lizenztext: http://www.gnu.org/licenses
#

bs="2048"
src="/dev/scd0"
target=""

#Checken ob das Device-File des Quell-Laufwerks existiert
if [[ ! -e $src  ]]
then
   read -p "Geben Sie das das Quell-Device an (absolut): " src
   
   if [[ -z $src  ]]
   then
     echo "Ohne ein Quell-Device kann das Script nicht arbeiten"
     exit
   fi
   
   if [[ ! -e $src  ]]
   then
     echo "Quell-Device existiert nicht"
     exit
   fi
fi

#Ziel-Datei checken
if [[ $# < 1 ]]
then
   read -p "Geben Sie das Ziel an (absolut)" target
   if [[ -z $target  ]]
   then
      echo "Ohne ein Ziel wäre es sinnlos"
      exit
   fi
else
   target=$1   
fi

#Bitweise in ein iso-File kopieren
dd if=$src of=$target bs=$bs

