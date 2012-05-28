#!/bin/bash

#
# Script, welches eine einfache Möglichkeit bietet, 
# mehrere mp3-Dateien zu einer zusammenzufügen und 
# wenn gewollt auch neu zu kodieren
#
# Autor: Philipp Böhm
# URL: http://www.tuxorials.de
# Lizenz: GNU General Public License v2
# Lizenztext: http://www.gnu.org/licenses
#
# TODO Möglichkeit des Taggings hinzufügen
#

ending="mp3"
tmpfile="/tmp/mergedmp3file.mp3"

#Parameterzahl
if [[ $# < 2 ]]
then
    echo Usage:  `basename $0` src-dir dest-file.mp3
    exit
fi

#Checken ob erster Parameter Verzeichnis ist
if [[ -d $1 ]]
then
    src=$1
else
    echo "erster Parameter muss ein Verzeichnis sein, dass existiert"
    exit
fi

#Checken ob zweiter Parameter kein Verzeichnis oder existiert
if [[ ! -e $2 ]] && [[ ! -d $2 ]]
then
    dest=$2
else
    echo "zweiter Parameter existiert oder ist ein Verzeichnis"
    exit
fi

#Tempfile vorsorglich löschen
if [[ -e $tmpfile  ]]
then
    rm $tmpfile
fi

#Dateien vereinigen
cat "$src"/*$ending > $tmpfile
echo "Das Temp-File hat eine Größe von: " + `du -sch $tmpfile | head -n1 | cut -f1`

#mit Lame neu transkodieren
echo
read -p "Soll das Temp-File mit LAME neu kodiert werden (j/n): " choice

if [[ $choice == 'j' ]] || [[ $choice == 'J' ]] || [[ $choice == '' ]]
then
    if [[ -n `which lame` ]]
    then  
        echo
        echo "Mögliche Bitraten:"
        echo "1 = 128 kBit/s"
        echo "2 = 192 kBit/s"
        echo "3 = 320 kBit/s"
        read -p "Geben Sie die Nummer für die Bitrate an (1,2,3): " bitrate
        
        if [[ $bitrate == 1 ]]
            then
            bitrate=128
        elif [[ $bitrate == 2 ]]
            then
            bitrate=192
        elif [[ $bitrate == 3 ]]
            then
            bitrate=320
        else
            echo "Die Bitrate existiert nicht, es wird 128 kBit/s gewählt"
            bitrate=128
        fi
        
        #transkodieren
        `which lame` -b $bitrate $tmpfile "$dest"
        echo "Dateien erfolgreich zusammengefügt"
        rm $tmpfile
    else
        echo "Lame-Encoder nicht vorhanden, Tempfile wird umbenannt"
        mv $tmpfile "$dest"
    fi
    
#Wenn es nicht neu transkodiert werden soll
else
    mv $tmpfile "$dest"
    if [[ -e "$dest" ]]
    then
        echo "Dateien erfolgreich zusammengefügt"
    else
        echo "Beim Verschieben des Tempfiles kam es zu einem Fehler"
    fi
fi


