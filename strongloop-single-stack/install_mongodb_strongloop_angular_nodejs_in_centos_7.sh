#!/bin/bash
#################################################################
# Script to install MongoDB, NodeJS, AngularJS and StrongLoop 
#
#################################################################

set -o errexit
set -o nounset
set -o pipefail

logfile="/var/log/install_mongodb_strongloop_angular_nodejs.log"

#update

echo "---update system---" | tee -a $logfile 2>&1 
yum update -y >> $logfile 2>&1 

#install mongodb

echo "---start installing mongodb---" | tee -a $logfile 2>&1
mongo_repo=/etc/yum.repos.d/mongodb-org-3.4.repo
cat <<EOT | tee -a $mongo_repo >> $logfile 2>&1 || { echo "---Failed to create mongo repo---" | tee -a $logfile; exit 1; }
[mongodb-org-3.4]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/\$releasever/mongodb-org/3.4/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-3.4.asc
EOT
yum install -y mongodb-org >> $logfile 2>&1 || { echo "---Failed to install mongodb-org---" | tee -a $logfile; exit 1; }
service mongod start >> $logfile 2>&1 || { echo "---Failed to start mongodb---" | tee -a $logfile; exit 1; }
echo "---finish installing mongodb---" | tee -a $logfile 2>&1


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
		
		echo "---start installing sample application---" | tee -a $logfile 2>&1 
		
		#create mongodb user
		dbUserPwd=$(date | md5sum | head -c 10)
		mongo admin --eval "db.createUser({user: \"sampleUser\", pwd: \"$dbUserPwd\", roles: [{role: \"userAdminAnyDatabase\", db: \"admin\"}]})" >> $logfile 2>&1 || { echo "---Failed to create MongoDB user---" | tee -a $logfile; exit 1; }
		
		#download and untar application
		yum install curl -y >> $logfile 2>&1 || { echo "---Failed to install curl---" | tee -a $logfile; exit 1; }
		curl -k -O https://raw.githubusercontent.com/camc-experimental/softlayer-postinstall-scripts/master/strongloop-single-stack/samples/single-stack-application.tar.gz >> $logfile 2>&1 || { echo "---Failed to download application tarball---" | tee -a $logfile; exit 1; } 
		tar -xzvf single-stack-application.tar.gz >> $logfile 2>&1 || { echo "---Failed to untar the application---" | tee -a $logfile; exit 1; }

		#start application
		cd strongloop-angular-mongo-sample
		sed -i -e "s/sampleUserPwd/$dbUserPwd/g" server/datasource.json >> $logfile 2>&1 || { echo "---Failed to configure datasource with mongo user password---" | tee -a $logfile; exit 1; } 
		slc run & >> $logfile 2>&1 || { echo "---Failed to start the application---" | tee -a $logfile; exit 1; }
		
		echo "---finish installing sample application---" | tee -a $logfile 2>&1 		
	
	else
		echo "---Indicator shows not to install sample application---" | tee -a $logfile
	fi	
else
	echo "---Failed to retrieve the indicator for sample application installation---" | tee -a $logfile
	exit 1
fi

