ZONE="europe-west1-d"
echo "finding internal address of the spark master (we deploy cassandra on the same node)"
NODE=$(gcloud compute instances list --filter="labels.sparkmaster=true" --format="value(name)")
echo "will install cassandra on ${NODE}"
gcloud compute ssh ${NODE} --zone ${ZONE} --command "wget -qO- "
