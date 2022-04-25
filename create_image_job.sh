#!/bin/bash

# Getting the command line utility of JSON parsing - jq utility

jq=C:/Users/AhmedNayyar/Downloads/jq-win64.exe

# Checking if the job with the present job name already exists or not
job_id=$(databricks jobs list | grep -w $job_name | awk {'print $1'})

# Create a job if does not exist 
if [ -z "$job_id" ]
then
	echo "Creating Job with Job Name : $job_name ....." 
    json_config_job=$( $jq -n \
                  --arg np "$notebook_path" \
                  --arg c_id "$cluster_id" \
                  --arg jn "$job_name" \
                  '{
            "notebook_task": {
              "notebook_path": $np
            },
            "existing_cluster_id": $c_id,
            "name": $jn,
            "max_concurrent_runs": 3,
            "timeout_seconds": 86400,
            "libraries": [],
            "email_notifications": {}
    }' )

    job_id=$(databricks jobs create --json "json_config_job" | $jq -r ".job_id")
    echo "Created job with Job Name : $job_name and Job Id : $job_id"
else
	echo "Job with Job Name : $job_name and Job Id : $job_id already exists...."
fi
    
