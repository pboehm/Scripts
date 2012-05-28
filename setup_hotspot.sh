#!/bin/bash

#
# Script, welches das Netbook so konfiguriert, 
# dass es als WLAN-HotSpot fungiert und NAT macht.
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


mess "`basename $0` - Copyright by Philipp Böhm"

###
# Vorraussetzungen checken
###
if [[ $USER != root ]]
then
	mess "Script erfordert root-Rechte"
	exit
fi

if [[ -z `which iptables` ]]
then
	mess "iptables nicht vorhanden, bitte nachinstallieren"
	exit
fi

if [[ -z `which hostapd` ]]
then
	mess "hostapd nicht vorhanden, bitte nachinstallieren"
	exit
fi

if [[ -z `which dhcpd` ]]
then
	mess "dhcpd nicht vorhanden, bitte nachinstallieren"
	exit
fi


###
# Scriptsteuerung
###
while getopts krh opt 2>/dev/null
do
   case $opt in 
     k) ###
		# Konfigurieren
		###
		
		mess "Setze die IP-Adresse für das Interface: wlan0"
		ifconfig wlan0 192.168.10.1

		mess "Starte hostapd"		
		service hostapd start
		
		# DNS-Server erfragen
		dnsserver=`cat /etc/resolv.conf | grep ^nameserver | head -n1 | cut -d " " -f2`
		if [[ $dnsserver == ""  ]]
		then 
		    dnsserver="8.8.8.8"
		fi
		sed -i "s/option domain-name-servers.*/option domain-name-servers ${dnsserver}\;/g" /etc/dhcp/dhcpd.conf
		echo "DNS-Server \"${dnsserver}\" wird an die Clients verbreitet"
		
		mess "Starte dhcpd"
		service dhcpd start

		mess "Lege mon.wlan0 als Interface für das WLAN-Netzwerk fest"
		in_interface="mon.wlan0"


		###
		# Interface AUSSEN
		interfaces=""
		for line in `ifconfig | cut -d " " -f1`
		do
			line=`echo -e $line`
			if [[ -z $line || $line == $in_interface || $line == "wlan0" ]]
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
		mess "Setze die Firewall-Regeln für das Masquerading"

		iptables --flush
		iptables --table nat --flush
		iptables --delete-chain
		iptables --table nat --delete-chain

		# Masquerading
		iptables --table nat --append POSTROUTING --out-interface $out_interface -j MASQUERADE

		###
		# Absicherung des tmt-Netzwerkes bei Freigabe der VPN-Verbindung
		if [[ $out_interface == "tun0" ]]
		then
			iptables -A FORWARD -p udp -d 10.8.0.1 --dport 53 -j ACCEPT
			iptables -A FORWARD -p tcp -d 10.8.0.1 --dport 53 -j ACCEPT
			iptables -A FORWARD -d 10.8.0.1 -j REJECT
			iptables -A FORWARD -d 192.168.168.0/24 -j REJECT
		else
			iptables --append FORWARD --in-interface $in_interface -j ACCEPT			
		fi
		

		mess "Schalte die Routing-Funktion des Kernels an"
		echo 1 > /proc/sys/net/ipv4/ip_forward		

		mess "Konfiguration erfolgreich"
	;;
	r)	###
		# Ausgangssituation herstellen
		###
		mess "Stelle die Ausgangssituation wieder her"
		service hostapd stop
		service dhcpd stop
		service iptables restart
		echo 0 > /proc/sys/net/ipv4/ip_forward
		echo "erfolgreich"
	;;	
	h|*)
		echo
		echo "`basename $0` [Option]"
		echo "  -k  konfiguriert den WLAN-Hotspot"
		echo "  -r  stellt die Ausgangssituation wieder her"
		echo "  -h  zeigt diese Hilfe an"
	  ;;
	
	esac
done

