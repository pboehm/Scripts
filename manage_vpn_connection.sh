#!/bin/bash
#
# Stellt komfortabel eine VPN-Verbindung her und baut diese auch wieder ab
#
# Autor: Philipp Böhm
# URL: http://www.tuxorials.de
# Lizenz: GNU General Public License v2
# Lizenztext: http://www.gnu.org/licenses
#

CONF="/etc/openvpn/client.conf"

ft=`tput bold`
rs=`tput sgr0`
function mess () {
	echo
	echo "${ft}${1}${rs}"
}


mess "`basename $0` - Copyright by Philipp Böhm"
echo

###
# Vorraussetzungen checken
###
if [[ $USER != root ]]
then
	mess "Script erfordert root-Rechte"
	exit
fi


###
# Funktion ermitteln
MODE="connect"
if [[ ! -z `pidof openvpn` ]]
then
	MODE="disconnect"
fi


###
# Verbindung aufbauen
###
if [[ $MODE == "connect" ]]
then
	read -p "Ist ein Proxy zu überbrücken (j/n): " choice

	if [[ ! -z `echo $choice | grep [jJyY]` ]]
	then
		
		# Proxy-Feature aktivieren
		echo
		for line in `cat $CONF | grep "^;http-proxy" $CONF` 
		do
			new=`echo $line | sed "s/\;//"`
			sed -i "s/${line}/${new}/g" $CONF
		done

		# Proxy-Host und Port erfragen
		existingproxy=`cat $CONF | grep "^http-proxy " | cut -d " " -f2,3`
		read -p "Sind die Informationen richtig [$existingproxy] (j/n): " choice
		if [[ -z `echo $choice | grep [jJyY]` ]]
		then
			echo
			read -p "Proxy-Host (als Hostname oder IP): " host
			read -p "Proxy-Port: " port
			sed -i "s/^http-proxy .*/http-proxy ${host} ${port}/" $CONF			
		fi 
		
	else
		sed -i "s/^http-proxy.*/;&/g" $CONF
	fi

    # OpenVPN letztendlich ausführen
	openvpn /etc/openvpn/client.conf &
fi


###
# Verbindung abbauen
###
if [[ $MODE == "disconnect" ]]
then
	mess "bestehende VPN-Verbindungen werden abgebaut"
	for pid in `pidof openvpn`
	do
		echo "Schließe Verbindung mit PID $pid"
		kill $pid
		echo
	done
fi
