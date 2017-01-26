#!/bin/bash
#################################################################
# Script to install NodeJS and AngularJS
#
#################################################################

set -o errexit
set -o nounset
set -o pipefail

logfile="/var/log/install_angular_nodejs.log"

#update

echo "---update system---" | tee -a $logfile 2>&1 
yum update -y >> $logfile 2>&1 

#install node.js

echo "---start installing node.js---" | tee -a $logfile 2>&1 
yum install epel-release -y >> $logfile 2>&1 || { echo "---Failed to install epel---" | tee -a $logfile; exit 1; }
yum install nodejs -y >> $logfile 2>&1 || { echo "---Failed to install node.js---"| tee -a $logfile; exit 1; }
echo "---finish installing node.js---" | tee -a $logfile 2>&1 

#install angularjs

echo "---start installing angularjs---" | tee -a $logfile 2>&1 
npm install -g grunt-cli bower yo generator-karma generator-angular >> $logfile 2>&1 || { echo "---Failed to install angular tools---" | tee -a $logfile; exit 1; }
yum install gcc ruby ruby-devel rubygems -y >> $logfile 2>&1 || { echo "---Failed to install ruby---" | tee -a $logfile; exit 1; }
gem install compass >> $logfile 2>&1 || { echo "---Failed to install compass---" | tee -a $logfile; exit 1; }
echo "---finish installing angularjs---" | tee -a $logfile 2>&1 
