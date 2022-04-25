#!/bin/bash

# Getting the command line utility of JSON parsing - jq utility

jq=C:/Users/AhmedNayyar/Downloads/jq-win64.exe
cluster_name="project_quantum"

# Getting the cluster_id corresponding to the cluster name
cluster_id=$(databricks clusters list | grep -w $cluster_name | awk {'print $1'} )
echo "Checking Cluster State of Cluster Name : $cluster_name with Cluster Id : $cluster_id"

# Getting the cluster state corresponding to the cluster_id

cluster_state=$(databricks clusters get --cluster-id $cluster_id | $jq -r ".state")
echo "Cluster State : $cluster_state"


# Start the cluster when it is in terminated state
if [ $cluster_state == "TERMINATED" ]
then
    echo "Starting Databricks Cluster"
    $(databricks cluster start --cluster-id $cluster_id)
    sleep 30
    cluster_state=$(databricks clusters get --cluster-id $cluster_id | jq -r ".state")
    echo "Cluster State : $cluster_state"
fi

# Wait when the cluster is in pending state

while [ $cluster_state == "PENDING" ]
do
  sleep 30
  cluster_state=$(databricks clusters get --cluster-id $cluster_id | jq -r ".state")
  echo "Cluster State : $cluster_state"
done

# Wait when the cluster is resizing
while [ $cluster_state == "RESIZING" ]
do
  sleep 30
  cluster_state=$(databricks clusters get --cluster-id $cluster_id | jq -r ".state")
  echo "Cluster State : $cluster_state"
done

# Exit when the cluster is in running state

if [ $cluster_state == "RUNNING" ]
then
    exit 0
else
    exit 1
fi
