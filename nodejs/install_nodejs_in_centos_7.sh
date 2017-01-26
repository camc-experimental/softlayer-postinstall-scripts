#!/bin/bash
#################################################################
# Script to install Node.js only
#
#################################################################

set -o errexit
set -o nounset
set -o pipefail

logfile="/var/log/install_nodejs.log"

echo "---start installing node.js---" | tee -a $logfile 2>&1 

yum install epel-release -y >> $logfile 2>&1 || { echo "---Failed to install epel---" | tee -a $logfile; exit 1; }
yum install nodejs -y >> $logfile 2>&1 || { echo "---Failed to install node.js---"| tee -a $logfile; exit 1; }

echo "---finish installing node.js---" | tee -a $logfile 2>&1 
