# README

The image build will use the HashiCorp Packer Light Docker Image to build the default images that are used by the current demo_build.

The current version creates the necessary Images in GCP for the twistlock-cto-lab and the twistlock-cto-partners projects and also for AWS. Azure will follow as soon as needed.

In GCE the produced image is saved as demo-build and in AWS it is saved within the region as AMI image with the name demo-build-timestamp.

## Prerequisits

To be able to use the automated build you need to have the following:

1. Your Google Cloud Service JSON file for the twistlock-cto-lab. If you don't have it you can create it at: https://console.cloud.google.com/iam-admin/serviceaccounts/project?project=cto-sandbox&pli=1

2. Save the JSON file as twistlock-cto-lab.json inside the files folder.

3. Your Google Cloud Service JSON file for the twistlock-cto-partners. If you don't have it you can create it at: https://console.cloud.google.com/iam-admin/serviceaccounts/project?project=twistlock-cto-partners&pli=1

4. Save the JSON file as twistlock-cto-partners.json inside the files folder.

5. AWS: Your AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY. Please make sure your account is part of the  twistlock-demo-image-build group to make sure you got the right permissions to build the image.

6. Save your AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY inside the environment variables of the docker-compose.yaml file

7. You must have Docker Compose installed on your local machine.

## How to use

 1. Open your terminal

 2. Change to the image_build folder

 3. Run the image_build playbook:

```
 docker-compose up
```

 4. Wait until the build is done. It will provision in GCE and AWS at the same time.  

## Last changes
 - 2018-12-10: Updated the image builder to support both GCE projects twistlock-cto-lab and the twistlock-cto-partners and using a simple docker compose file. Removed Ansible.
 - 2018-10-21: Wrapped this in Docker & Ansible, updated readme.
 - 20.09.2018: Created the default
