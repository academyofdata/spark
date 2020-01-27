#!/bin/bash
ZONE="europe-west1-d"
MACHINE="n1-standard-2"

#we install on the same machine as spark master, if no machine has sparkmaster label, we spin up a new server
MASTER=$(gcloud compute instances list --filter="labels.sparkmaster=true" --format="get(networkInterfaces[0].networkIP)")
if [ -z "$MASTER" ]
then
    MASTER="local[*]"
else
    MASTER="spark://${MASTER}:7077"
fi
CASSANDRA=$(gcloud compute instances list --filter="labels.cassandra=true" --format="get(networkInterfaces[0].networkIP)")

NODE=$(gcloud compute instances list --filter="labels.sparkmaster=true" --format="value(name)")

if [ -z "$NODE" ]
then
    NODE="zeppelin"
    gcloud compute instances create ${NODE} --zone ${ZONE} --machine-type ${MACHINE} --maintenance-policy "MIGRATE" --image "https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts" --boot-disk-size "40" --boot-disk-type "pd-standard" --boot-disk-device-name "${NODE}disk" --labels "zeppelin=true"
    echo "waiting for the server to boot..."
    sleep 25
else    
    gcloud compute instances add-labels ${NODE} --zone ${ZONE} --labels=zeppelin=true
fi
if [ ! -z "$CASSANDRA" ]
then
    CASSANDRA="-c ${CASSANDRA}"
fi
echo "will install zeppelin with master ${MASTER} and cassandra node ${CASSANDRA}"
gcloud compute ssh ${NODE} --zone ${ZONE} --command "wget -qO- https://raw.githubusercontent.com/academyofdata/spark/master/deploy-zeppelin.sh | bash -s -- -m ${MASTER} ${CASSANDRA} -s zeplpassw! -d mysql:mysql-connector-java:8.0.18,com.databricks:spark-avro_2.11:4.0.0"
