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

curl -k -o $WORKDIR/sample-application.tar.gz https://raw.githubusercontent.com/camc-experimental/softlayer-postinstall-scripts/master/strongloop-three-tiers/samples/three-tier-strongloop-sample-application.tar.gz
tar -xzvf $WORKDIR/sample-application.tar.gz -C $WORKDIR

sed -i -e "s/mongodb-server/$MongoDB_Server/g" $WORKDIR/strongloop-sample/server/datasources.json 
sed -i -e "s/sampleUserPwd/$DBUserPwd/g" $WORKDIR/strongloop-sample/server/datasources.json 
slc run $WORKDIR/strongloop-sample &

echo "---finish installing strongloop sample application---" | tee -a $logfile 2>&1 
exit 0
