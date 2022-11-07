![Twistlock Demo Build](https://github.com/twistlock/demo_build/raw/edge/terraform/scripts/demo%20build.png)

## Wiki
Get more detailed information on the demo build project [here](https://github.com/twistlock/demo_build/wiki)

## Release Notes

Find the latest release notes [here](https://github.com/twistlock/demo_build/wiki/Release-Notes)


## Demo Guides

Find example Demo Guides [here](https://github.com/twistlock/demo_build/wiki/Demo-Guides)

## Get Help

If you have trouble with the demo build process, please join us on the demo_build [hangouts room](https://chat.google.com/room/AAAAbEeLHeo) and check out the [troubleshooting guide](https://github.com/twistlock/demo_build/wiki/Demo-Build-Troubleshooting).

## Overview

The ansible demo build is available as a docker container to ensure a consistent build environment each time you execute it. This gives us the following benefits.
1. No Ansible installation on your machine.
2. Once you stabilize your configuration, much more consistent execution.
3. Easy to update to new demo-build-releases without having to manage playbooks, etc.
4. Cross Platform compatibility

Due to these benefits, this is the recommended way to build the demo environment. If you are still utilizing an older method of building the demo environment, please convert over to docker-compose as soon as possible.

This does mean you must have docker and docker-compose installed. Please follow the instructions found [here](https://docs.docker.com/compose/install/) to install docker-ce and docker-compose for your operating system.

## Architecture

Once you have docker and docker-compose installed on your machine, you will create a `demo_build_config` directory in your user's home directory. This is where you will store your Ansible configuration file, Let's Encrypt Certificates, Ansible Variables, and your inventory file. These are necessary to determine what machines will be configured, as well as what variables will be used in the demo buildout. This directory will be mounted as a volume within the ansible-demo-build docker container that is launched by docker-compose. Ansible will then connect over the GCP API as well as SSH to build your demo environment and provision the nodes specified in your inventory.yaml.

A visual representation of this is below.

```
 +-----------------------------+                       +--------------------------------------+
 |                             |                       |                                      |
 |                             |                       |                                      |
 | +-------------------------+ |                       |    +---------------------------+     |
 | |                         | |                       |    |                           |     |
 | |   Ansible Demo Build    | |                       |    | demo.x.lab.twistlock.com  |     |
 | |   Container             | |        SSH            |    |                           |     |
 | |                     +------------------------------->  +---------------------------+     |
 | |                         | |      GCP API          |                                      |
 | |                         | |                       |    +---------------------------+     |
 | |                         | |                       |    |                           |     |
 | +-------------------------+ |                       |    | demo-node.x.twistlock.com |     |
 | |  Docker Volume:         | |                       |    |                           |     |
 | |  ~/demo_build_config    | |                       |    +---------------------------+     |
 | |                         | |                       |                                      |
 | |                         | |                       |    +---------------------------+     |
 | +-------------------------+ |                       |    |                           |     |
 |                             |                       |    | temp.x.twistlock.com      |     |
 +-----------------------------+                       |    |                           |     |
 |             Docker          |                       |    +---------------------------+     |
 |                             |                       |                                      |
 +-----------------------------+                       +--------------------------------------+
 |             Laptop          |                       |        Google Cloud Platform         |
 |                             |                       |                                      |
 +-----------------------------+                       +--------------------------------------+
```
## Using image from GCR

As the docker images used in the build are located on GCR, please authenticate to be able to pull the appropriate images. You can do this using the [gcloud utility](https://cloud.google.com/sdk/docs/#install_the_latest_cloud_tools_version_cloudsdk_current_version).
This method presupposes you're starting from scratch.  As a prerequisite, you do need to enable authentication to GCR (`gcloud auth configure-docker`
More information can be found [here](https://cloud.google.com/container-registry/docs/overview?hl=en_US).


## Planning

You will be creating your own sub-domain in the **lab.twistlock.com domain** (_samantha_.lab.twistlock.com).  You will create a named resource under this sub-domain (_demo_.samantha.lab.twistlock.com) and all your published resources will put a prefix in front of this (console-demo, jenkins-demo, etc).


## Prerequisites

If you have existing configuration files, run `prep_docker.sh` to create ~/demo_build_config and move all the necessary config files there, then skip to the execution section

If you're starting from scratch:
1. Request a service account for your use be created from Patrick in the format of [NAME]-ansible-svc
2. Go to https://console.cloud.google.com/iam-admin/serviceaccounts/project?project=cto-sandbox&pli=1 and generate a key for your [NAME]-ansible-svc account.

3. Create ~/demo_build_config
4. Obtain .json file for your GCP service account and copy to ~/demo_build_config/files/twistlock-cto-lab-[MYFILE].json (replacing [MYFILE] with whatever the rest of the filename is..."neil-1234567" for example).
5. Copy [group_vars/all_template.yml](playbooks/group_vars/all_template.yml) to ~/demo_build_config/group_vars/all.yml.  Change values as needed.  Particularly
  * `new_password` -- set this to the master password you'll use to access the portal.
  * `service_account_email` and `credentials_file`
  * `domain_root`
  * `twistlock_registry_token` and `twistlock_license`
  * `twistlock_release_url` -- set this to the release you intend to install

  For partners pay attention to
  * `domain_root` -- should have the form of `partner_name.p.twistlock.com`
  * `dns_zone` -- must be `p.twistlock.com`
  * `project_id` -- must be `twistlock-cto-partners`

  A sample configuration is found below
  ```
  target_user: paul

  new_password: botanist.spearman.petty.untimed.drainpipe.breath

  emailaddr: paul@twistlock.com

  users:
    - username: pierre
      fullname: Pierre D. Fox
      password: ..generate..
      groups:
        - admins
        - devops

  service_account_email: paul-ansible-svc@cto-sandbox.iam.gserviceaccount.com

  credentials_file: files/twistlock-cto-lab-[MYFILE].json

  domain_root: [YOURNAME].lab.twistlock.com

  twistlock_registry_token: [Twistlock access token]
  twistlock_license: [base64 license blob]

  ```
6. Copy [template_inventory.yml](playbooks/template_inventory.yml) to ~/demo_build_config/inventory.yml.  Edit as needed, particularly replacing `samantha` with your username.

   For partners, copy [template_partner_inventory.yml](playbooks/template_partner_inventory.yml) to ~/demo_build_config/inventory.yml and replace `partner` with the partner's company name, for example.

5. Copy [docker-compose.yml](docker-compose.yml) to a local working directory.

6. Create a ~/demo_build_config/.ansible.cfg
```
[defaults]
private_key_file=/root/.ssh/samantha-gce
remote_user=samantha
host_key_checking=False
log_file=/var/log/ansible.log
```
Replace remote_user with your GCE username and samantha-gce with the name of the cert you use for GCE.

7. Copy the cert and public key (samantha-gce, samantha-gce.pub) in step 5 to ~/demo_build_config/.ssh/

An example of a working directory tree is the following:
```
~/demo_build_config/
├── .ansible.cfg
├── .ssh
│   ├── id_rsa
│   ├── id_rsa.pub
│   ├── known_hosts
│   └── known_hosts.old
├── files
│   ├── defender.ps1
│   ├── demo.x.lab.twistlock.com
│   │   └── creds
│   │       └── x
│   ├── demo.x.lab.twistlock.com_vault_config.txt
│   ├── twistlock-cto-sandbox-xxxxxx.json
│   └── wildcard_cert
│       └── x.lab.twistlock.com
│           ├── cert.pem
│           ├── chain.pem
│           └── privkey.pem
├── group_vars
│   └── all.yml
└── inventory.yml
```


## Running the Build
8. *If you're using a non-standard location for your demo_build_config or if your inventory isn't named inventory.yml*:
  * `export demo_build_config=~/test/demo_build_config`
  * `export inventory=inventory_other_lab.yml`
9. If you're prerelease and you've mapped the Team Drive somewhere nonstandard (other than /Volumes/GoogleDrive/Team Drives/Releases/):
  * `export prerelease=/mnt/TeamDrive/Releases/`
10. (optional) Export the following environment variable to use the latest additions/features:
  * `export demo_build_tag=edge`
11. Test your configuration:
  * `docker-compose run test`
12. Use docker-compose to run it
  * If you're running the whole thing without additional switches:
    `docker-compose run ansible-demo-build`
  * If you need to pass parameters:
    `docker-compose run ansible-demo-build -i ./inventory.yml my_lab.yml --start-at-task="Run scenarios"` -- be sure to pass in the "-i ./inventory.yml my_lab.yml" along with your additional parameters.

## Results
After playbook completes, simply browse to portal at ```<console host in inventory.yml>```` and you can then navigate to console, jenkins, etc.  For example:  

	https://demo.matthew.lab.twistlock.com

### Playbook Results

* `https://console-<identifier>.<name>.lab.twistlock.com:8083`
  - Twistlock console with users created and license already installed
* `http://jenkins-<identifier>.<name>.lab.twistlock.com/`
  -  Jenkins with projects configured
* `http://sockshop-<identifier>.<name>.lab.twistlock.com/` --> Sock Shop
* `https://<console>:5000/` --> registry
* `http://splunk-<identifier>.<name>.lab.twistlock.com/` --> Splunk
* `https://<console>:8050/` --> DVWA, only accessible with SSH port forwarding
  * (`ssh -L 8050:localhost:8050 <user>@<console>.lab.twistlick.com`)
  * user: **admin** password: **password**
* Unless windows install skipped, Windows Server will be at:
  `demo-windows.<name>.lab.twistlock.com`

***You can log into console, jenkins, or splunk with any user/pw combination from group_vars/all.yml***

### Credentials

If you indicated in your `group_vars/all.yml` that you wanted your passwords generated, you can find the credentials under ~/demo_build_config/files/demo.\<user>.lab.twistlock.com/creds

## Updating your environment

You can update to the latest demo-build environment by running `docker-compose pull` from the directory where you have your docker-compose.yaml file stored. This will pull the latest ansible-demo-build containers from gcr.io and will allow you to build an environment with the latest successful build.

After this, rebuild your environment using the same steps from [execution](#execution)

## Using locally synched source (for dev/etc)

0. SUGGESTED:  Move your Twistlock license from roles/role_console/files/license_file.json into group_vars/all.yml in a twistlock_license: variable.  Move only the value of the license and not the whole JSON.

  twistlock_license: [base64 license blob]

1. Run `prep_docker.sh` to create ~/demo_build_config and move all the necessary config files there.
2. `docker-compose build`
3. *If you're using a non-standard location for your demo_build_config or if your inventory isn't named inventory.yml*:
  * `export demo_build_config=~/test/demo_build_config`
  * `export inventory=inventory_other_lab.yml`
4. If you're prerelease and you've mapped the Team Drive somewhere nonstandard (other than /Volumes/GoogleDrive/Team Drives/Releases/):
  * `export prerelease=/mnt/TeamDrive/Releases/`
4. Use docker-compose to run it
  * If you're running the whole thing without additional switches:
    `docker-compose run ansible-demo-build-local`
  * If you need to pass parameters:
    `docker-compose run ansible-demo-build-local -i ./inventory.yml my_lab.yml --start-at-task="Run scenarios"` -- be sure to pass in the "-i ./inventory.yml my_lab.yml" along with your additional parameters.

# NEW!! Terraform Build Process

Terraform can now be used for building out your demo environment. This functionality is new, but should be a great step forward towards more consistent builds.

To use the new terraform build process on the central machine please follow the instructions at: https://github.com/twistlock/demo_build/wiki/Central-Build-Server


## For admins of the central build machine

This section is only important if you need to setup the build machine

1. Make sure Docker CE is installed. Example for Ubuntu 16.04: https://docs.docker.com/install/linux/docker-ce/ubuntu/

2. Make sure Docker Compose is installed. Example for Ubuntu 16.04: https://www.digitalocean.com/community/tutorials/how-to-install-docker-compose-on-ubuntu-16-04

3. Clone the current demo build deploy script https://github.com/twistlock/demo_build/blob/terraform/terraform/scripts/demo_build.sh

4. Move the demo build deploy script to /usr/bin/demo_build.sh

5. Make sure it is executable for everyone

`sudo chmod a+x /usr/bin/demo_build.sh`

6. Create the docker group

`sudo groupadd docker`
