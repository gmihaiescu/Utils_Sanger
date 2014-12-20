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

instances=`ls -l reports/ | grep report | wc -l`
not_1.0.2=`cat reports/* | grep "instance is not running Sanger 1.0.2" | wc -l`
failed_at_upload=`cat reports/*  | grep "workflows that failed at the upload step" | egrep -v 0 | wc -l`
failed_at_other_steps=`cat reports/*  | grep "workflows that failed at the upload step" | grep 0 | wc -l`

echo "There are $instances running in this environment."
echo "There are $not_1.0.2 workflows not running Sanger 1.0.2"
echo "There are $failed_at_upload workflows that failed at the upload step." 
echo "There are $failed_at_other_steps workflows that failed at steps other than upload." 
