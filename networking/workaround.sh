#!/bin/bash

touch sample.txt

mkdir userdata
mount /dev/xvdh1 userdata 
cd userdata

PRIVATE_GATEWAY=$(cat meta.js | python -c 'import json,sys; unwrap1=json.load(sys.stdin)[0]; map=json.loads(unwrap1); print map["gateway"];')
EXAMPLE_VM_NUMBER=$(cat meta.js | python -c 'import json,sys; unwrap1=json.load(sys.stdin)[0]; map=json.loads(unwrap1); print map["example_vm_number"];')

if [ $EXAMPLE_VM_NUMBER == "vm3" ]; then
	VPN_SUBNET=$(cat meta.js | python -c 'import json,sys; unwrap1=json.load(sys.stdin)[0]; map=json.loads(unwrap1); print map["vpn_subnet"];')
	echo "$VPN_SUBNET via $PRIVATE_GATEWAY" >> /etc/sysconfig/network-scripts/route-eth0
	service network restart
fi


if [ $EXAMPLE_VM_NUMBER == "vm3" ]; then
	sed -i -e 's/ONBOOT=yes/ONBOOT=no/g' /etc/sysconfig/network-scripts/ifcfg-eth1
	echo "GATEWAY=$PRIVATE_GATEWAY" >> /etc/sysconfig/network-scripts/ifcfg-eth0	
	service network restart
fi