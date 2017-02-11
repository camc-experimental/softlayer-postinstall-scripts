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
yum install gcc ruby ruby-devel rubygems make -y >> $logfile 2>&1 || { echo "---Failed to install ruby---" | tee -a $logfile; exit 1; }
gem install compass >> $logfile 2>&1 || { echo "---Failed to install compass---" | tee -a $logfile; exit 1; }
echo "---finish installing angularjs---" | tee -a $logfile 2>&1 

#install sample application

Strongloop_Server=$1
		
echo "---start installing angularjs sample application---" | tee -a $logfile 2>&1 
WORKDIR=/root		
		
#download and untar application
curl -k -o $WORKDIR/sample-application.tar.gz https://raw.githubusercontent.com/camc-experimental/softlayer-postinstall-scripts/master/strongloop-three-tiers/samples/three-tier-angular-sample-application.tar.gz >> $logfile 2>&1 || { echo "---Failed to download application tarball---" | tee -a $logfile; exit 1; } 
tar -xzvf $WORKDIR/sample-application.tar.gz -C $WORKDIR >> $logfile 2>&1 || { echo "---Failed to untar the application---" | tee -a $logfile; exit 1; }		

#start application
sed -i -e "s/strongloop-server/$Strongloop_Server/g" $WORKDIR/angular-sample/server/server.js >> $logfile 2>&1 || { echo "---Failed to configure server.js---" | tee -a $logfile; exit 1; } 
sed -i -e "s/8080/8090/g" $WORKDIR/angular-sample/server/server.js >> $logfile 2>&1 || { echo "---Failed to change listening port in server.js---" | tee -a $logfile; exit 1; } 
node $WORKDIR/angular-sample/server/server.js & >> $logfile 2>&1 || { echo "---Failed to start the application---" | tee -a $logfile; exit 1; }
		
echo "---finish installing angularjs sample application---" | tee -a $logfile 2>&1 		

