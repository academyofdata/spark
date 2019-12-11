#!/bin/bash
ZONE="europe-west1-d"
#we install on the same machine as spark master
NODE=$(gcloud compute instances list --filter="labels.sparkmaster=true" --format="value(name)")

gcloud compute instances add-labels ${NODE} --zone ${ZONE} --labels=kafkabroker=true,zookeeper=true

echo "will install kafka with on ${NODE}"
gcloud compute ssh ${NODE} --zone ${ZONE} --command "wget -qO- https://raw.githubusercontent.com/academyofdata/spark/master/deploy-kafka.sh | bash -s -- --zep /opt/zeppelin"
