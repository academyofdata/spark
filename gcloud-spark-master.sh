ZONE="europe-west1-d"
MACHINE="n1-standard-2"
NODE="spark01"

if [ $# -ge 1 ]
then
        NODE=$1
fi


if [ $# -ge 2 ]
then
        MACHINE="n1-standard-$2"
fi

echo "using ${NODE} as instance name"

gcloud compute instances create ${NODE} --zone ${ZONE} --machine-type ${MACHINE} --maintenance-policy "MIGRATE" --image "https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts" --boot-disk-size "40" --boot-disk-type "pd-standard" --boot-disk-device-name "${NODE}disk" --labels "sparkmaster=true,aodcluster=true"
echo "waiting for the machine to boot"
sleep 30

echo "installing spark on remote node"
gcloud compute ssh ${NODE} --zone ${ZONE} --command "wget -qO- https://raw.githubusercontent.com/academyofdata/spark/master/deploy-spark.sh | bash -s -- --java --master"

echo "finding internal address of the node"
IPADDR=$(gcloud compute instances list --filter="name=${NODE}" --format="value(networkInterfaces[0].networkIP)")

echo "master IP is ${IPADDR}"
