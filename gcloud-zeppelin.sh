#!/bin/bash
ZONE="europe-west1-d"
MASTER=$(gcloud compute instances list --filter="labels.sparkmaster=true" --format="value(name)")
CASSANDRA=$(gcloud compute instances list --filter="labels.cassandra=true" --format="value(name)")


echo "will install zeppelin with master ${MASTER}"
gcloud compute ssh ${NODE} --zone ${ZONE} --command "wget -qO- https://raw.githubusercontent.com/academyofdata/spark/master/deploy-zeppelin.sh | bash -s -- -m ${MASTER} -c ${CASSANDRA} -s zeplpassw!"
