#!/bin/bash
#
# Ermöglicht die Konfiguration von NAT über bestimmte Interfaces
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
while getopts krh opt 2>/dev/null
do
   case $opt in 
     k) ###
		# Konfigurieren
		###
		if [[ -z `which iptables` ]]
		then
			mess "iptables nicht vorhanden, bitte nachinstallieren"
			exit
		fi

		# Interface INNEN
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

		mess "Welches Interface zeigt nach ${rs}innen${ft} (ins Netzwerk)"
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
		in_interface=$choice


		# Interface AUSSEN
		###
		interfaces=""
		for line in `ifconfig | cut -d " " -f1`
		do
			line=`echo -e $line`
			if [[ -z $line || $line == $in_interface ]]
			then
				continue
			else
				interfaces="$interfaces $line"
			fi
		done

		mess "Welches Interface zeigt nach ${rs}aussen${ft} (ins Internet)"
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
		out_interface=$choice

		###
		# Firewall-Regeln setzen setzen
		###
		echo
		echo -n "Setze die Firewall-Regeln für das Masquerading ..."

		iptables --flush
		iptables --table nat --flush
		iptables --delete-chain
		iptables --table nat --delete-chain

		# Set up IP FORWARDing and Masquerading
		iptables --table nat --append POSTROUTING --out-interface $out_interface -j MASQUERADE
		iptables --append FORWARD --in-interface $in_interface -j ACCEPT
		echo " abgeschlossen"
		
		
		###
		# Routing im Kernel anschalten
		###
		echo
		echo -n "Schalte die Routing-Funktion des Kernels an ..."
		echo 1 > /proc/sys/net/ipv4/ip_forward
		echo " abgeschlossen"

		mess "Die Konfiguration ist nun abgeschlossen"
	  ;;
	r)	###
		# Konfiguration entfernen
		###
		mess "Stelle die Ausgangskonfiguration wieder her"
		echo 0 > /proc/sys/net/ipv4/ip_forward
		service iptables restart
		mess "abgeschlossen"
	  ;;
	h|*)
		echo
		echo "`basename $0` [Option]"
		echo "  -k  konfiguriert die NAT"
		echo "  -r  stellt die Ausgangssituation wieder her"
		echo "  -h  zeigt diese Hilfe an"
	  ;;
	
	esac
done

