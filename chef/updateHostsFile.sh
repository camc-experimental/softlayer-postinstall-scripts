#!/bin/bash
#################################################################
# Script to update etc/hosts file with chef server ip
#
#         Copyright IBM Corp. 2012, 2017
#################################################################

#set -o errexit
#set -o nounset
#set -o pipefail

LOGFILE="/var/log/updateHostsFile.log"

echo "---start hostname, ip address setup---" | tee -a $LOGFILE 2>&1

yum install curl -y
yum install bind-utils -y

MYIP=$(hostname --ip-address)
echo "---my ip address is $MYIP---" | tee -a $LOGFILE 2>&1

MYHOSTNAME=$(dig -x $MYIP +short | sed -e 's/.$//')
echo "---my dns hostname is $MYHOSTNAME---" | tee -a $LOGFILE 2>&1

mkdir userdata
mount /dev/xvdh1 userdata 

CHEFIP=$(cat userdata/meta.js | python -c 'import json,sys; unwrap1=json.load(sys.stdin)[0]; map=json.loads(unwrap1); print map["chefIP"];')
echo "---my chef server ip is $CHEFIP---" | tee -a $LOGFILE 2>&1

CHEFHOSTNAME=$(cat userdata/meta.js | python -c 'import json,sys; unwrap1=json.load(sys.stdin)[0]; map=json.loads(unwrap1); print map["chefHostname"];')
echo "---my chef server hostname is $CHEFHOSTNAME---" | tee -a $LOGFILE 2>&1

CHEFDNSHOSTNAME=$(dig -x $CHEFIP +short | sed -e 's/.$//')
echo "---my chef server dns hostname is $CHEFDNSHOSTNAME---" | tee -a $LOGFILE 2>&1

echo $CHEFIP $CHEFHOSTNAME >> /etc/hosts

echo "---hosts file updates successfully---" | tee -a $LOGFILE 2>&1 
