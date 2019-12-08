ZONE="europe-west1-d"
echo "finding internal address of the spark master (we deploy cassandra on the same node)"
NODE=$(gcloud compute instances list --filter="labels.sparkmaster=true" --format="value(name)")
echo "will install cassandra on ${NODE}"
gcloud compute ssh ${NODE} --zone ${ZONE} --command "wget -qO- https://raw.githubusercontent.com/academyofdata/spark/master/deploy-cassandra.sh | bash"

gcloud compute instances add-labels ${NODE} --zone ${ZONE} --labels=cassandra=true