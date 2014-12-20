#!/bin/bash
#set -x

report="reports"
user="USER"
key="PATH_TO_YOUR_KEY"

unsecure="-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
rm -rf $report
mkdir $report


echo "Copying the script to tmp"
for instance in `cat list`;\
do scp $unsecure -i $key script.sh  $user@$instance:/tmp;\
ssh $unsecure -i $key $user@$instance "chmod +x /tmp/script.sh; /tmp/script.sh" > $report/${instance}_report.txt
done

