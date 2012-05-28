#!/bin/bash
#
# Beschreibung
#
# Autor: Philipp Böhm
# URL: http://www.tuxorials.de
# Lizenz: GNU General Public License v2
# Lizenztext: http://www.gnu.org/licenses
#
ip_address="192.168.10.1"
ft=`tput bold`
rs=`tput sgr0`
function mess () {
	echo
	echo "${ft}${1}${rs}"
}


mess "`basename $0` - Copyright by Philipp Böhm"

###
# Vorraussetzungen checken
###
if [[ $USER != root ]]
then
	mess "Script erfordert root-Rechte"
	exit
fi

###
# Scriptsteuerung
###
while getopts hkr opt 2>/dev/null
do
   case $opt in 
	k)
		###
		# Konfigurieren
		
		# Interface erfragen
		###
		for line in `ifconfig | cut -d " " -f1`
		do
			line=`echo -e $line`
			if [[ -z $line ]]
			then
				continue
			else
				interfaces="$interfaces $line"
			fi
		done

		mess "Welches Interface hängt in dem entsprechenden Netzwerk"
		for intf in $interfaces
		do
			echo "  $intf"	
		done
		echo "----------"
		read -p "${ft}Ihre Wahl: ${rs}" choice

		while [[ -z `echo $interfaces | grep -w "$choice"` ]]
		do
			read -p "Interface existiert nicht, bitte korrigieren: " choice
		done
		interface=$choice
		
		###
		# IP-Adresse setzen
		mess "Setze die IP-Adresse für das Interface: $interface"
		ifconfig $interface 192.168.10.1
		
		###
		# DNS-Server erfragen
		dnsserver=`cat /etc/resolv.conf | grep ^nameserver | head -n1 | cut -d " " -f2`
		if [[ $dnsserver == ""  ]]
		then 
		    dnsserver="8.8.8.8"
		fi
		sed -i "s/option domain-name-servers.*/option domain-name-servers ${dnsserver}\;/g" /etc/dhcp/dhcpd.conf
		echo "DNS-Server \"${dnsserver}\" wird an die Clients verbreitet"
		
		###
		# DHCPD starten
		mess "Starte dhcpd"
		service dhcpd start
	  ;;
	r)	###
		# Ausgangssituation herstellen
		###
		mess "Stelle die Ausgangssituation wieder her"
		service dhcpd stop
		echo "erfolgreich"
	;;
	h|*)
		echo
		echo "`basename $0` [Option]"
		echo "  -h  zeigt diese Hilfe an"
	  ;;
	esac
done

