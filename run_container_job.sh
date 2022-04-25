#!/bin/bash

# Getting the command line utility of JSON parsing - jq utility

jq=C:/Users/AhmedNayyar/Downloads/jq-win64.exe
job_name="container_job"
job_id=$(databricks jobs list | grep -w $container_job | awk {'print $1'})

# Running the job for making image of the model
run_id=$(databricks jobs run-now --job-id $job_id | $jq -r ".run_id")
echo "Running Job with Run Id : $run_id"

# Get the state of the run started
run_state=$(databricks runs get --run-id $run_id | $jq -r ".state.life_cycle_state")
echo "Run Sate " $run_state"

while [ $run_id == "RUNNING" ] || [ $run_id == "PENDING" ]
do
    sleep 30 
    run_state=$(databricks runs get --run-id $run_id | $jq -r ".state.life_cycle_state") 
    echo "Run State : $run_state"
done

# Getting the result state and state message of the terminated job
result_state=$(databricks runs get --run-id $run_id | $jq -r ".state.result_state")
state_msg=$(databricks runs get --run-id $run_id | $jq -r ".state.state_message")
echo "Job Id : $job_id with Result State : $result_state and State Message : $state_msg"

# Create a metastore and push the image in it if run succeded otherwise exit gracefully
if [ $result_state == "SUCCESS" ]
then
    echo "Pushing the image of the model to the metastore"
    mkdir -p metadata
    databricks runs get-output --run-id $run_id | $jq  -r "notebook_output.result" | tee metadata/container_image.json
    echo "Pushed image to metastore"
    exit 0
else
    echo "Run with Run Id : $run_id failed....."
    exit 1
fi
