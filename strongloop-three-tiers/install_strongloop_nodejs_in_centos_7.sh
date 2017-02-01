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

#install sample application

mkdir userdata
mount /dev/xvdh1 userdata 

SAMPLE=$(cat userdata/meta.js | python -c 'import json,sys; unwrap1=json.load(sys.stdin)[0]; map=json.loads(unwrap1); print map["sample"];')
SAMPLE=$(echo "$SAMPLE" | tr '[:upper:]' '[:lower:]')

if [ -n "$SAMPLE" ]; then
	if [ "$SAMPLE" == "true" ]; then
		
		MongoDB_Server=$(cat userdata/meta.js | python -c 'import json,sys; unwrap1=json.load(sys.stdin)[0]; map=json.loads(unwrap1); print map["mongodb-server"];')
		DBUserPwd=$(cat userdata/meta.js | python -c 'import json,sys; unwrap1=json.load(sys.stdin)[0]; map=json.loads(unwrap1); print map["mongodb-user-password"];')

		echo "---start installing sample application---" | tee -a $logfile 2>&1 
		
		#download and untar application
		yum install curl -y >> $logfile 2>&1 || { echo "---Failed to install curl---" | tee -a $logfile; exit 1; }
		curl -k -O https://raw.githubusercontent.com/camc-experimental/softlayer-postinstall-scripts/master/strongloop-three-tiers/samples/three-tier-strongloop-sample-application.tar.gz >> $logfile 2>&1 || { echo "---Failed to download application tarball---" | tee -a $logfile; exit 1; } 
		tar -xzvf three-tier-strongloop-sample-application.tar.gz >> $logfile 2>&1 || { echo "---Failed to untar the application---" | tee -a $logfile; exit 1; }		

		#start application
		cd strongloop-sample
		sed -i -e "s/mongodb-server/$MongoDB_Server/g" server/datasources.json >> $logfile 2>&1 || { echo "---Failed to configure datasource with mongodb server address---" | tee -a $logfile; exit 1; }
		sed -i -e "s/sampleUserPwd/$DBUserPwd/g" server/datasources.json >> $logfile 2>&1 || { echo "---Failed to configure datasource with mongo user password---" | tee -a $logfile; exit 1; } 
		slc run & >> $logfile 2>&1 || { echo "---Failed to start the application---" | tee -a $logfile; exit 1; }
		
		echo "---finish installing sample application---" | tee -a $logfile 2>&1 		
	
	else
		echo "---Indicator shows not to install sample application---" | tee -a $logfile
	fi	
else
	echo "---Failed to retrieve the indicator for sample application installation---" | tee -a $logfile
	exit 1
fi

