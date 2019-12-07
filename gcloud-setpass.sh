#!/bin/bash
LABEL="aodcluster"

NODES=$(gcloud compute instances list --format="value(name)" --filter="status=RUNNING AND labels.${LABEL}=true")

for N in ${NODES}
do
  echo "running on ${N}
done
