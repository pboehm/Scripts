#!/bin/bash
#
# Konfiguriert Mediatomb entsprechend der verbundenen Interfaces
#
# Autor: Philipp Böhm
# URL: http://www.tuxorials.de
# Lizenz: GNU General Public License v2
# Lizenztext: http://www.gnu.org/licenses
#

if [[ $USER != root ]]
then
	mess "Script erfordert root-Rechte"
	exit
fi

MEDIATOMB_INTERFACE=em1
if [[ `ifconfig wlan0 | grep inet | wc -l` > 0 ]]
then
    MEDIATOMB_INTERFACE=wlan0
fi

sed -i "s/MT_INTERFACE.*/MT_INTERFACE=\"${MEDIATOMB_INTERFACE}\"/" /etc/mediatomb.conf

service mediatomb restart
