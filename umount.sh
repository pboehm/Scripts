#!/bin/bash
#
# Script zum komfortablen Aushängen von Laufwerken
#
# Autor: Philipp Böhm
# URL: http://www.tuxorials.de
# Lizenz: GNU General Public License v2
# Lizenztext: http://www.gnu.org/licenses
#
ft=`tput bold`
rs=`tput sgr0`
und=`tput smul`
function mess () {
	echo
	echo "${ft}${1}${rs}"
}

base_mountpoint=/media
upd_sindex="updateserienindex"
indexdir="/home/philipp/Serien/.index/"
um="sudo umount"
count=0
mpoints=""

###
# Mögliche Partitionen auflisten
###
mess "${und}Mögliche Partitionen zum Aushängen:${rs}"
for mountpoint in `cat /proc/mounts | grep " $base_mountpoint" | cut -d " " -f2`
do
	if [[ -f $mountpoint/.umount_info ]]
	then
		count=`expr "$count" + 1`
		mountpoints[$count]=$mountpoint
		device=`cat /proc/mounts | grep $mountpoint | cut -d " " -f1`
		product=`grep ProductName $mountpoint/.umount_info | cut -d= -f2`
		size=`grep Size $mountpoint/.umount_info | cut -d= -f2`
		echo " ${ft}(${count})${rs} $mountpoint ${ft}($device)${rs} - $product - $size"
		mpoints="$mpoints $mountpoint"
	fi
done

###
# Wenn keine Partitionen vorhanden ... beenden
###
if [[ -z $mpoints ]]
then
	mess "Keine aushängbaren Partitonen"
	exit
fi

###
# Optionen zusammenbauen
###
for (( i = 1; i <= `echo $mpoints | wc -w`; i++ )); do
	if [[ -z $nmbrs ]]
	then
		nmbrs=$i
	else
		nmbrs="$nmbrs/$i"
	fi
done

###
# Befehle auswerten
###
read -p "Geben Sie die nötigen Befehle an ($nmbrs/a/q): " choice
case $choice in
	[1-9])
		mountpoint=`echo $mpoints | cut -d" " -f$choice`
		all=false
		;;
	a|A)
		all=true
		;;
	q|Q|*)
		echo "wird beendet ..."
		exit
		;;
esac

###
# Funktionsdeklaration
###
function backup {
   `which backup` "$@" --config-file=~/.backup/config.rb
}

function make_backup () {
	if [[ `cat $1/.umount_info | grep ^EnableBackup | cut -d= -f2` == true ]]
	then
		mess "Führe Backup auf `basename $1` durch ..."

		if [[ -n `basename $1 | grep "fap" ` ]]; then
		    backup perform --trigger=backup_hdd_fap
		fi

		if [[ -n `basename $1 | grep "tos" ` ]]; then
		    backup perform --trigger=backup_hdd_tos
		fi
	fi
}

function make_upd_sindex () {
	if [[ `cat $1/.umount_info | grep ^HasSeries | cut -d= -f2` == true ]]
	then
		mess "Führe Update des Serien-Indexes auf `basename $1` durch"
		seriesdir=`cat $1/.umount_info | grep ^SeriesDir | cut -d= -f2`
		if [[ -z $seriesdir ]]
		then
			return 1
		fi
		$upd_sindex $indexdir`basename $1`

		#neue XML-Dateien erstellen
		createserienindex --path=$1/Serien/ --index=$indexdir`basename $1`.xml
	fi
}

###
# Aktionen ausführen
###
if [[ $all == true ]]
then
	# Serien updaten
	for i in $mpoints
	do
		make_upd_sindex $i
	done

	# Backup ausführen
	for i in $mpoints
	do
		make_backup $i
	done

	# aushängen
	for i in $mpoints
	do
		mess "Hänge $i aus"
		$um $i
	done

else
	# Serien updaten
	make_upd_sindex $mountpoint

	# Backup ausführen
	make_backup $mountpoint

	# aushängen
	mess "Hänge $mountpoint aus"
	$um $mountpoint
fi
