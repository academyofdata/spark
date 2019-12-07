#!/bin/bash
LABEL="aodcluster"

NODES=$(gcloud compute instances list --format="value(zone,name)" --filter="status=RUNNING AND labels.${LABEL}=true")

for N in ${NODES}
do
  echo "running on ${N}"
  #gcloud compute ssh ${N} --command "wget -qO- https://raw.githubusercontent.com/academyofdata/spark/master/config-setpass.sh | bash -s -- $1 $2"
done
