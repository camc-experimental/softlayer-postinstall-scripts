#!/bin/bash
#################################################################
# Script to install MongoDB
#
#         Copyright IBM Corp. 2017, 2017
#################################################################

set -o errexit
set -o nounset
set -o pipefail

logfile="/var/log/install_mongodb.log"

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

#install sample application

mkdir userdata
mount /dev/xvdh1 userdata 

SAMPLE=$(cat userdata/meta.js | python -c 'import json,sys; unwrap1=json.load(sys.stdin)[0]; map=json.loads(unwrap1); print map["sample"];')
SAMPLE=$(echo "$SAMPLE" | tr '[:upper:]' '[:lower:]')

if [ -n "$SAMPLE" ]; then
	if [ "$SAMPLE" == "true" ]; then
		
		DBUserPwd=$(cat userdata/meta.js | python -c 'import json,sys; unwrap1=json.load(sys.stdin)[0]; map=json.loads(unwrap1); print map["mongodb-user-password"];')
		
		echo "---start installing sample application---" | tee -a $logfile 2>&1 
		
		#create mongodb user and allow external access
		mongo admin --eval "db.createUser({user: \"sampleUser\", pwd: \"$DBUserPwd\", roles: [{role: \"userAdminAnyDatabase\", db: \"admin\"}]})" >> $logfile 2>&1 || { echo "---Failed to create MongoDB user---" | tee -a $logfile; exit 1; }
		sed -i -e 's/  bindIp/#  bindIp/g' etc/mongod.conf >> $logfile 2>&1 || { echo "---Failed to configure mongod---" | tee -a $logfile; exit 1; }
		service mongod restart >> $logfile 2>&1 || { echo "---Failed to restart mongod---" | tee -a $logfile; exit 1; }
				
		echo "---finish installing sample application---" | tee -a $logfile 2>&1 		
	
	else
		echo "---Indicator shows not to install sample application---" | tee -a $logfile
	fi	
else
	echo "---Failed to retrieve the indicator for sample application installation---" | tee -a $logfile
	exit 1
fi

