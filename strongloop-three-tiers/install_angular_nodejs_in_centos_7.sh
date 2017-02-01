#!/bin/bash
#################################################################
# Script to install NodeJS and AngularJS
#
#         Copyright IBM Corp. 2017, 2017
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

#install sample application

mkdir userdata
mount /dev/xvdh1 userdata 

SAMPLE=$(cat userdata/meta.js | python -c 'import json,sys; unwrap1=json.load(sys.stdin)[0]; map=json.loads(unwrap1); print map["sample"];')
SAMPLE=$(echo "$SAMPLE" | tr '[:upper:]' '[:lower:]')

if [ -n "$SAMPLE" ]; then
	if [ "$SAMPLE" == "true" ]; then
		
		Strongloop_Server=$(cat userdata/meta.js | python -c 'import json,sys; unwrap1=json.load(sys.stdin)[0]; map=json.loads(unwrap1); print map["strongloop-server"];')
		
		echo "---start installing sample application---" | tee -a $logfile 2>&1 
		
		#download and untar application
		yum install curl -y >> $logfile 2>&1 || { echo "---Failed to install curl---" | tee -a $logfile; exit 1; }
		curl -k -O https://raw.githubusercontent.com/camc-experimental/softlayer-postinstall-scripts/master/strongloop-three-tiers/samples/three-tier-angular-sample-application.tar.gz >> $logfile 2>&1 || { echo "---Failed to download application tarball---" | tee -a $logfile; exit 1; } 
		tar -xzvf three-tier-angular-sample-application.tar.gz >> $logfile 2>&1 || { echo "---Failed to untar the application---" | tee -a $logfile; exit 1; }		

		#start application
		cd angular-sample
		sed -i -e "s/strongloop-server/$Strongloop_Server/g" server/server.js >> $logfile 2>&1 || { echo "---Failed to configure server.js---" | tee -a $logfile; exit 1; } 
		node server/server.js & >> $logfile 2>&1 || { echo "---Failed to start the application---" | tee -a $logfile; exit 1; }
		
		echo "---finish installing sample application---" | tee -a $logfile 2>&1 		
	
	else
		echo "---Indicator shows not to install sample application---" | tee -a $logfile
	fi	
else
	echo "---Failed to retrieve the indicator for sample application installation---" | tee -a $logfile
	exit 1
fi

