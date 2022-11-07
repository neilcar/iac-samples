#!/bin/sh

# Author: Neil Carpenter
# Purpose: Copy existing demo_build config
#.         for docker usage

export DEMO_BUILD_CONFIG=$HOME/demo_build_config



mkdir $DEMO_BUILD_CONFIG
mkdir $DEMO_BUILD_CONFIG/.ssh
mkdir $DEMO_BUILD_CONFIG/group_vars
mkdir $DEMO_BUILD_CONFIG/files
mkdir $DEMO_BUILD_CONFIG/files/wildcard_cert


cp ./group_vars/all.yml $DEMO_BUILD_CONFIG/group_vars/all.yml

# move GCP service account file to files/ and
# update reference in all.yml
sudo cp ./twistlock-*.json $DEMO_BUILD_CONFIG/files/
sed -i.bak 's#\./twistlock-#files/twistlock-#g' group_vars/all.yml

cp ./inventory* $DEMO_BUILD_CONFIG/
cp ~/.ssh/* $DEMO_BUILD_CONFIG/.ssh/
cp ~/.ansible.cfg $DEMO_BUILD_CONFIG/
DEMO_BUILD_KEYPATH=$(grep private_key_file $DEMO_BUILD_CONFIG/.ansible.cfg | awk '{len=split($0,a,"/"); print "/root/.ssh/"a[len]}')
sed -i.bak "s#private_key_file=.*#private_key_file=$DEMO_BUILD_KEYPATH#" $DEMO_BUILD_CONFIG/.ansible.cfg
sudo cp -r ./files/wildcard_cert/ $DEMO_BUILD_CONFIG/files/

# Docker container will run as root on Linux
# and as your user account on MacOS
# Permissions on .ssh files need to match
sudo chown root $DEMO_BUILD_CONFIG/.ssh/*

# That will fail to run on MacOS, leaving the permissions as they should be.
