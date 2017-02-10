#!/bin/bash
#################################################################
# Script to install NodeJS and StrongLoop 
#
#################################################################

set -o errexit
set -o nounset
set -o pipefail

logfile="/var/log/install_strongloop_nodejs.log"

#update

echo "---update system---" | tee -a $logfile 2>&1 
yum update -y >> $logfile 2>&1 

#install node.js

echo "---start installing node.js---" | tee -a $logfile 2>&1 
yum install epel-release -y >> $logfile 2>&1 || { echo "---Failed to install epel---" | tee -a $logfile; exit 1; }
yum install nodejs -y >> $logfile 2>&1 || { echo "---Failed to install node.js---"| tee -a $logfile; exit 1; }
echo "---finish installing node.js---" | tee -a $logfile 2>&1 

#install strongloop

echo "---start installing strongloop---" | tee -a $logfile 2>&1 
yum groupinstall 'Development Tools' -y >> $logfile 2>&1 || { echo "---Failed to install development tools---" | tee -a $logfile; exit 1; }
npm install -g strongloop >> $logfile 2>&1 || { echo "---Failed to install strongloop---" | tee -a $logfile; exit 1; }
echo "---finish installing strongloop---" | tee -a $logfile 2>&1 

