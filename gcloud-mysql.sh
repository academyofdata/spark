#!/bin/bash
ZONE="europe-west4-b"
NODE="mysql"
MACHINE="g1-small"

gcloud compute instances create ${NODE} --zone ${ZONE} --machine-type ${MACHINE} --maintenance-policy "MIGRATE" --image "https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts" --boot-disk-size "10" --boot-disk-type "pd-standard" --boot-disk-device-name "${NODE}disk" --labels "mysql=true,aodcluster=true"
echo "waiting for the machine to boot"
sleep 30

echo "will install mysql on ${NODE}"
gcloud compute instances add-labels ${NODE} --zone ${ZONE} --labels=mysql=true

gcloud compute ssh ${NODE} --zone ${ZONE} --command "wget -qO- https://raw.githubusercontent.com/academyofdata/spark/master/deploy-mysql.sh | bash"
