#!/bin/bash
#
# Konfiguriert Mediatomb entsprechend der verbundenen Interfaces
#
# Autor: Philipp Böhm
# URL: http://www.tuxorials.de
# Lizenz: GNU General Public License v2
# Lizenztext: http://www.gnu.org/licenses
#

ft=`tput bold`
rs=`tput sgr0`
function mess () {
	echo
	echo "${ft}${1}${rs}"
}

if [[ $USER != root ]]
then
	mess "Script erfordert root-Rechte"
	exit
fi

mess "`basename $0` - Copyright by Philipp Böhm"
###
# Scriptsteuerung
###
while getopts srkh opt 2>/dev/null
do
    case $opt in 
        s)
            MEDIATOMB_INTERFACE=wlan0
            if [[ `ifconfig p4p1 | grep inet | wc -l` > 0 ]]
            then
                MEDIATOMB_INTERFACE=p4p1
            fi

            sed -i "s/MT_INTERFACE.*/MT_INTERFACE=\"${MEDIATOMB_INTERFACE}\"/" /etc/mediatomb.conf

            # Multicast-Route hinzufügen
            route add -net 239.0.0.0 netmask 255.0.0.0 $MEDIATOMB_INTERFACE
            ifconfig $MEDIATOMB_INTERFACE allmulti

            service mediatomb start
        ;;
	    r)	
            service mediatomb restart
        ;;
        k) 
	        service mediatomb stop
        ;;
	    h|*)
		    echo
		    echo "`basename $0` [Option]"
		    echo "  -s  startet Mediatomb und setzt das aktive Interface"
		    echo "  -r  Mediatomb wird neugestartet"
		    echo "  -k  Mediatomb wird beendet"
		    echo "  -h  zeigt diese Hilfe an"
        ;;
	
	esac
done

