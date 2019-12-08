#!/bin/bash
ZONE="europe-west1-d"
NODE=$(gcloud compute instances list --filter="labels.sparkmaster=true" --format="value(name)")
CASSANDRA=$(gcloud compute instances list --filter="labels.cassandra=true" --format="value(name)")
MASTER="spark://${NODE}:7077"


echo "will install zeppelin with master ${MASTER} and cassandra node ${CASSANDRA} "
gcloud compute ssh ${NODE} --zone ${ZONE} --command "wget -qO- https://raw.githubusercontent.com/academyofdata/spark/master/deploy-zeppelin.sh | bash -s -- -m ${MASTER} -c ${CASSANDRA} -s zeplpassw!"
