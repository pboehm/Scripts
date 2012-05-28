#!/bin/bash
#
# Script that disables fprintd depending on the status of the display lid
# it uses authconfig which is used on systems like Fedora, RHEL, Centos
#
# author: Philipp Böhm

# change this depending on your hardware
LID_STATE_FILE="/proc/acpi/button/lid/LID/state"

if [[ ! -e $LID_STATE_FILE ]]; then
    echo "lid state file does not exist"
    exit 1
fi

AUTHCONFIG=`which authconfig`
if [[ ! -e $AUTHCONFIG ]]; then
    echo "authconfig not exisiting, but required"
    exit 1
fi

# this file holds the current state of authconfig (0: disabled; 1: enabled)
FPRINTD_STATUS_FILE="/run/fprintd.status"
[[ ! -e $FPRINTD_STATUS_FILE ]] && touch $FPRINTD_STATUS_FILE

FPRINTD_STATUS=`cat $FPRINTD_STATUS_FILE`
FPRINTD_STATUS=`echo -n $FPRINTD_STATUS`

LID_STATUS=`cut -d: -f2 $LID_STATE_FILE | sed "s/ //g"`

# change the fprintd state if required
if [[ $LID_STATUS == "open" && ($FPRINTD_STATUS == 0 || -z $FPRINTD_STATUS) ]]
then
    echo 1 > $FPRINTD_STATUS_FILE
    $AUTHCONFIG --enablefingerprint --update
fi

if [[ $LID_STATUS == "closed" && $FPRINTD_STATUS == 1 ]]; then
    echo 0 > $FPRINTD_STATUS_FILE
    $AUTHCONFIG --disablefingerprint --update
fi
