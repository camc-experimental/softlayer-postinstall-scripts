#!/bin/bash
#################################################################
# Script to install Kubernetes Minion Node
#
#         Copyright IBM Corp. 2012, 2016
#################################################################

#set -o errexit
#set -o nounset
#set -o pipefail

LOGFILE="/var/log/createCAMUser.log"

apt-get update | tee -a $LOGFILE 2>&1
apt-get install python-minimal -y | tee -a $LOGFILE 2>&1

echo "---start createCAMUser---" | tee -a $LOGFILE 2>&1

mkdir userdata
mount /dev/xvdh1 userdata 

CAMUSER=$(cat userdata/meta.js | python -c 'import json,sys; unwrap1=json.load(sys.stdin)[0]; map=json.loads(unwrap1); print map["uid"];')
CAMPWD=$(cat userdata/meta.js | python -c 'import json,sys; unwrap1=json.load(sys.stdin)[0]; map=json.loads(unwrap1); print map["pwd"];')
echo "---CAMUSER $CAMUSER---" | tee -a $LOGFILE 2>&1 
echo "---CAMPWD $CAMPWD---" | tee -a $LOGFILE 2>&1 
PASS=$(perl -e 'print crypt($ARGV[0], "password")' $CAMPWD)
useradd -m -p $PASS $CAMUSER
echo "$CAMUSER ALL=(ALL:ALL) NOPASSWD:ALL" | (EDITOR="tee -a" visudo)

echo "---finished creating CAMUser $CAMUSER---" | tee -a $LOGFILE 2>&1 