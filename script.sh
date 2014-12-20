#!/bin/bash
#set -x
counter_failed_at_upload=0

swid=`sudo -u seqware -i /home/seqware/bin/seqware workflow list | grep -A 3 "Version                  | 1.0.2" | grep "SeqWare Accession" | cut -d"|" -f2`
if [ -z "$swid" ]
then echo "instance is not running Sanger 1.0.2"
exit 2
fi

current_workflow_status=`sudo -u seqware -i /home/seqware/bin/seqware workflow report --accession $swid | grep -A3 "RECORD 0" | grep "Workflow Run Status" | cut -d"|" -f2`

if [ $current_workflow_status == "running" ]
	then running_time=`sudo -u seqware -i /home/seqware/bin/seqware workflow report --accession $swid | grep -A21 "RECORD 0"|grep "Workflow Run Time" | cut -d"|" -f2`
	echo "workflow has been running for  $running_time"
elif [ $current_workflow_status == "failed" ]
	then 
		for workflow in `sudo -u seqware -i /home/seqware/bin/seqware workflow report --accession $swid| grep -A 4 -B 1 failed| grep 'Workflow Run Engine ID'| awk -F"|" '{print $2}'`;\
		do \
        		upload_status=`oozie job -info $workflow -oozie http://localhost:11000/oozie | grep ERROR| grep -i upload| wc -l`
				if [ $upload_status -eq 1 ]
					then counter_failed_at_upload=$((counter_failed_at_upload+1))
        			fi
		done
		echo "There were $counter_failed_at_upload workflows that failed at the upload step."
fi

