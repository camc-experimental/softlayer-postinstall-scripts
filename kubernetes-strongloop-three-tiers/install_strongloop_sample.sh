#!/bin/bash
#################################################################
# Script to install StrongLoop sample application
#
#################################################################

set -o errexit
set -o nounset
set -o pipefail

logfile="/var/log/install_strongloop_nodejs.log"

#install sample application

MongoDB_Server=$1
DBUserPwd=$2

echo "---start installing strongloop sample application---" | tee -a $logfile 2>&1 
WORKDIR=/root

curl -k -o $WORKDIR/sample-application.tar.gz https://raw.githubusercontent.com/camc-experimental/softlayer-postinstall-scripts/master/strongloop-three-tiers/samples/three-tier-strongloop-sample-application.tar.gz >> $logfile 2>&1 || { echo "---Failed to download application tarball---" | tee -a $logfile; exit 1; }
tar -xzvf $WORKDIR/sample-application.tar.gz -C $WORKDIR >> $logfile 2>&1 || { echo "---Failed to untar the application---" | tee -a $logfile; exit 1; }

sed -i -e "s/mongodb-server/$MongoDB_Server/g" $WORKDIR/strongloop-sample/server/datasources.json >> $logfile 2>&1 || { echo "---Failed to configure datasource with mongodb server address---" | tee -a $logfile; exit 1; }
sed -i -e "s/sampleUserPwd/$DBUserPwd/g" $WORKDIR/strongloop-sample/server/datasources.json >> $logfile 2>&1 || { echo "---Failed to configure datasource with mongo user password---" | tee -a $logfile; exit 1; }
slc run $WORKDIR/strongloop-sample >> $logfile 2>&1 || { echo "---Failed to start the application---" | tee -a $logfile; exit 1; }

echo "---finish installing strongloop sample application---" | tee -a $logfile 2>&1 

