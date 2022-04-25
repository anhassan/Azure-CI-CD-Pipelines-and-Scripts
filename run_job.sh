#!/bin/bash

# Getting the command line utility of JSON parsing - jq utility

jq=C:/Users/AhmedNayyar/Downloads/jq-win64.exe
job_name="training_job"
job_id=$(databricks jobs list | grep -w $job_name | awk {'print $1'})

# Running the job created for training
echo "Running job with Job Name : $job_name with Job Id : $job_id"
run_id=$(databricks jobs run-now --job-id $job_id | 4jq -r ".run_id")
echo "Running Job with Run Id : $run_id"

# Get the state of the job started
run_state=$(databricks runs get --run-id $run_id | $jq -r ".state.life_cycle_state")
echo "Run State : $run_state of Run Id : $run_id"

# Wait for running or pending job
while [ $run_state == "RUNNING" ] || [ $run_state == "PENDING" ]
do
  sleep 30
  run_state=$(databricks runs get --run-id $run_id | jq -r ".state.life_cycle_state")
  echo "Run State : $run_state of Run Id : $run_id"
done

# Getting the result state and state message of the terminated job
result_state=$(databricks runs get --run-id $run_id | jq -r ".state.result_state")
state_msg=$(databricks runs get --run-id $run_id | jq -r ".state.state_message")
echo "Job Id : $job_id with Result State : $result_state and State Message : $state_msg"

# Exit gracefully if run was successful otherwise throw error
if [ $result_state == "SUCCESS" ]
then
    echo "Run Id : $run_id completed successfully....."
    exit 0
else
    echo "Run Id : $run_id failed......"
    exit 1
fi
