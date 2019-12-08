#!/bin/bash
ZONE="europe-west1-d"
#we install on the same machine as spark master
MASTER=$(gcloud compute instances list --filter="labels.sparkmaster=true" --format="get(networkInterfaces[0].networkIP)")
MASTER="spark://${MASTER}:7077"
CASSANDRA=$(gcloud compute instances list --filter="labels.cassandra=true" --format="get(networkInterfaces[0].networkIP)")

NODE=$(gcloud compute instances list --filter="labels.sparkmaster=true" --format="value(name)")


gcloud compute instances add-labels ${NODE} --zone ${ZONE} --labels=zeppelin=true

echo "will install zeppelin with master ${MASTER} and cassandra node ${CASSANDRA} "
gcloud compute ssh ${NODE} --zone ${ZONE} --command "wget -qO- https://raw.githubusercontent.com/academyofdata/spark/master/deploy-zeppelin.sh | bash -s -- -m ${MASTER} -c ${CASSANDRA} -s zeplpassw! -d mysql:mysql-connector-java:8.0.18,com.databricks:spark-avro_2.11:4.0.0"
