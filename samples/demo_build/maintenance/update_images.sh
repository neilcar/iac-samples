#!/bin/bash

echo "Update Images"

docker pull gcr.io/cto-sandbox/cto/ansible-demo-build:edge
docker pull gcr.io/cto-sandbox/cto/ansible-demo-build:latest
docker pull gcr.io/cto-sandbox/cto/terraform-demo-build:edge
docker pull gcr.io/cto-sandbox/cto/terraform-demo-build:latest

echo "Done updating images"
