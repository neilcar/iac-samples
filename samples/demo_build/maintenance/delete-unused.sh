#!/bin/sh

echo "Delete unused reserved IPs"
echo "Read the current Reserved but not used IPs"
gcloud compute addresses list --filter "STATUS=RESERVED" --format="table(name)" > names.txt
echo "Wait for some seconds so file is there"
sleep 5
while read ip; do
  if [ "$ip" != "NAME" ]; then
  	echo "Deleting unused static IP $ip"
  	gcloud compute addresses delete $ip --verbosity=debug -q --region us-central1
  fi
done <names.txt
