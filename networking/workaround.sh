#!/bin/bash

touch sample.txt

mkdir userdata
mount /dev/xvdh1 userdata 
cd userdata

GATEWAY=$(cat meta.js | python -c 'import json,sys; unwrap1=json.load(sys.stdin)[0]; map=json.loads(unwrap1); print map["gateway"];')
EXAMPLE_VM_NUMBER=$(cat meta.js | python -c 'import json,sys; unwrap1=json.load(sys.stdin)[0]; map=json.loads(unwrap1); print map["example_vm_number"];')

echo $GATEWAY >> /root/sample.txt
echo $EXAMPLE_VM_NUMBER >> /root/sample.txt