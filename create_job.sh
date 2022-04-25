#!/bin/bash

# Getting the command line utility of JSON parsing - jq utility

jq=C:/Users/AhmedNayyar/Downloads/jq-win64.exe
job_name="Training_Job"
notebook_path="Shared/Execution/dummy_train"
cluster_name="project_quantum"
cluster_id=$(databricks clusters list | grep -w $cluster_name | awk {'print $1'})

# Getting the job id corresponding to the job name if it exists
job_id=$(databricks jobs list | grep -w $job_name | awk {'print $1'})

#Create a new job if job with specified name doesnot exist
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
    echo "JSON_Config: $json_config_job"
          
    job_id=$(databricks jobs create --json $json_config_job | $jq -r ".job_id")
    echo "Created Job Name : $job_name with Job Id : $job_id....."
else
    echo "Job with Job Name : $job_name already exists......"
fi
