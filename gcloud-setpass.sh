#!/bin/bash
LABEL="aodcluster"

NODES=$(gcloud compute instances list --format="csv[no-heading](name,zone)" --filter="status=RUNNING AND labels.${LABEL}=true")

for N in ${NODES}
do
  echo "running with ${N}"
  echo ${N} | awk -F, '{print "gcloud compute ssh " $1 " --zone " $2 " --command \"wget -qO- https://raw.githubusercontent.com/academyofdata/spark/master/config-setpass.sh | bash -s -- $1 $2 \""}' | bash -s -- $1 $2
done
