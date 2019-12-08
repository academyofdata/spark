ZONE="europe-west1-d"
MACHINE="n1-standard-1"
NODE="spark02"

if [ $# -ge 1 ]
then
        NODE=$1
fi

if [ $# -ge 2 ]
then
        MACHINE="n1-standard-$2"
fi

echo "using ${NODE} as instance name"

gcloud compute instances create ${NODE} --zone ${ZONE} --machine-type ${MACHINE} --maintenance-policy "MIGRATE" --image "https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts" --boot-disk-size "40" --boot-disk-type "pd-standard" --boot-disk-device-name "${NODE}disk" --labels "sparkslave=true,aodcluster=true"
echo "waiting for the machine to boot"
sleep 30

echo "finding internal address of the master"
MASTERIP=$(gcloud compute instances list --filter="labels.sparkmaster=true" --format="get(networkInterfaces[0].networkIP)")
echo "master IP is ${MASTERIP}"

echo "installing and configuring Spark on remote node"
gcloud compute ssh ${NODE} --zone ${ZONE} --command "wget -qO- https://raw.githubusercontent.com/academyofdata/spark/master/deploy-spark.sh | bash -s -- --java --slaveof spark://${MASTERIP}:7077"
