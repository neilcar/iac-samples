#!/bin/bash

# Author: Andreas Wilke
# Description: This script is used to prepare and execute the demo build configuration.
# It was mainly designed to run on the central build machine but can also be used on a local MAC OS or Linux machine.


# Global flags
# Location of logs. Default is the $HOME/twistlock-demo-build.log
deployment_log="$HOME/twistlock-demo-build.log"
# Parameters
demo_build_config="demo_build_config"
# Exit on any errors of commands
set -e
# Silence tput errors when script is run by process not attached to a terminal
tput_silent() {
  tput "$@" 2>/dev/null
}

# Different print options
# Print for tasks executed
print_task() {
  info=$1
  echo "$(tput_silent setaf 5)$info.$(tput_silent sgr0)"
  echo $info >> $deployment_log
}

# Print for information messages
print_info() {
  info=$1
  echo "$(tput_silent setaf 2)$info.$(tput_silent sgr0)"
  echo $info >> $deployment_log
}

# Print for error messages
print_error() {
  error=$1
  echo "$(tput_silent setaf 1)$error.$(tput_silent sgr0)"
  echo $error >> $deployment_log
}

# Print for warning messages
print_warning() {
  warning=$1
  echo "$(tput_silent setaf 3)$warning.$(tput_silent sgr0)"
  echo $warning >> $deployment_log
}

# Stop the program and exit with the given message
exit_now() {
  print_error "$@"
  exit 1
}

# parse_yaml function will parse the yaml input file and creates the variables for each of them.
parse_yaml() {
  local prefix=$2
  local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
  sed -ne "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
  awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

# check_tools is used to check if all the necessary tools and binaries like docker, docker-compose and tree are installed on the machine that is used to execute.
check_tools () {
  if [ -x "$(command -v docker)" ]; then
    print_info "Found Docker and it's executable"
    if [ -x "$(command -v docker-compose)" ]; then
      print_info "Found Docker Compose and it's executable"
      if [ -x "$(command -v tree)" ]; then
        print_info "Found tree command and it's executable"
      else
        print_warning "Did not find the tree command on your system! Please make sure to install tree (brew install tree on MacOS)"
       	exit_now "Failed to find the tree command!"
      fi
    else
      print_warning "Did not find Docker Compose on your system! Please make sure to install Docker Compose"
     	exit_now "Failed to find Docker Compose!"
    fi
  else
    print_warning "Did not find Docker on your system! Please make sure to install Docker"
   	exit_now "Failed to find Docker!"
  fi
}

# check_configuration checks the configuration inputs before it will be possible to deploy an environment.
check_configuration() {
  print_info "Check necessary tools"
  check_tools
  print_info "Check the current configuration"
  # Check if the input file is available and is using the right extension
  if [ ${myyml: -4} == ".yml" ]; then
    print_info "YAML file $myyml is using the right extension .yml"
  else
    print_warning 'Your YAML file is not using the right extension .yml'
   	exit_now "Make sure it is a real .yml file!"
  fi

  if [ ! -f $myyml ]; then
    print_warning "Demo Build file $myyml not found. Please make sure to create this file to be able to use the demo build"
   	exit_now "Failed to finde the Demo Build file!"
  fi

  # read yaml file
  eval $(parse_yaml $myyml "input_")

  # access yaml content
  print_info "You specified the following input parameters"
  print_info "username: $input_demo_build_username"

  # Check if user did specify a username
  if [ "$(uname)" = "Darwin" ]; then
    if [ "$input_demo_build_username" = "batman" ]; then
       print_warning "I'm sure you are not Batman! Please change your username!"
       exit_now "You did not specify the right username!"
    fi
  else
    if [ "$input_demo_build_username" != "$username" ]; then
      print_warning "You did specifiy a username $input_demo_build_username that is not equal to your local username $username!"
      exit_now "You did not specify the right username!"
    fi
  fi

  print_info "buildname: $input_demo_build_buildname"
  print_info "password: $input_demo_build_password"

  # Check if user did specify a password
  if [ "$input_demo_build_password" = "Joker" ]; then
    print_warning "I'm sure you are not using the password of Batman! Please change your password!"
    exit_now "You did not specify the right password!"
  fi

  # Check for special characters inside a password that are not supported by the demo build
  if [[ $input_demo_build_password = *['!'@\'\$%^\&*()_+]* ]]; then
    print_warning "There is a special character inside the password $input_demo_build_password that are not supported"
    exit_now 'Do not use the special characters like !@\$%^\&*()_+]*'
  else
    print_info "Didn't find none allowed characters inside the password"
  fi

  print_info "email: $input_demo_build_email"

  # Check if user did specify their email
  if [ "$input_demo_build_email" = "batman@twistlock.com" ]; then
    print_warning "I'm sure you are not Batman! Please change your email!"
    exit_now "You did not specify the right E-Mail!"
  fi

  print_info "license: $input_demo_build_license"

  # Check if license file exists
  if [ ! -f $input_demo_build_license ]; then
    print_warning"License file not found! Make sure you specified the right license file"
    exit_now "Please specify the right license file!"
  fi

  print_info "Output of license file:"
  demo_build_license="$(cat $input_demo_build_license)"
  print_info $demo_build_license
  print_info "token: $input_demo_build_token"
  print_info "Service Account E-Mail: $input_demo_build_service_account_email"
  print_info "Credentials file: $input_demo_build_gitbranch"

  # Check if the variable gitbranch is specified.
  if [ -z "$input_demo_build_gitbranch" ]; then
      print_warning "The gitbranch to use variable is empty"
      exit_now "Please specify the gitbranch that should be used! (Example gitbranch: edge for latest and greatest)"
  else
      print_info "$input_demo_build_gitbranch git branch used"
  fi

  # Check if the variable environment is specified.
  if [ -z "$input_demo_build_environment" ]; then
      print_warning "The environment to use variable is empty"
      exit_now "Please specify the environment that should be used! (Example cto-sandbox and twistlock-cto-partners)"
  else
      print_info "$input_demo_build_environment environment used"
      if [ "$input_demo_build_environment" = "cto-sandbox" ]; then
         print_info "Correct environment variable configured!"
      else
        if [ "$input_demo_build_environment" = "twistlock-cto-partners" ]; then
         print_info "Correct environment variable configured!"
        else
         exit_now "You did not specify the right environment variable! Only cto-sandbox and twistlock-cto-partners is supported!"
        fi
      fi
  fi

  print_info "Install Twistlock Version: $input_demo_build_twistlock_install_version"

  # Check if credentials file exists
  if [ ! -f $input_demo_build_credentials_file ]; then
    print_warning "Credentials file not found! Make sure you specified the right credential file"
    exit_now "The credential file was not found!"
  fi

  # Check if credentials file for dns is defined.
  if [ "$input_demo_build_credentials_file_dns" = "" ]; then
      print_info "No credential file for DNS specified."
  else
      print_info "Credentials file for dns specified as $input_demo_build_credentials_file_dns. Try to find it"
      if [ ! -f $input_demo_build_credentials_file_dns ]; then
        print_warning "Credentials file for DNS not found! Make sure you specified the right credential file"
        exit_now "The credential file was not found!"
      else
        print_info "Found the credential file for DNS."
      fi
  fi

  print_info "SSH Private key: $input_demo_build_ssh_private"

  # Check if SSH private key exists
  if [ ! -f $input_demo_build_ssh_private ]; then
    print_warning "SSH private key not found!"
    exit_now "SSH private key not found!"
  fi

  print_info "SSH Public key: $input_demo_build_ssh_public"

  # Check if SSH public key exists
  if [ ! -f $input_demo_build_ssh_public ]; then
    print_warning "SSH public key not found!"
    exit_now "SSH public key not found!"
  fi

  # Check if the right K8s CNI network is specified.
  print_info "K8S CNI Plugin: $input_demo_build_k8s_cni"
  if [ "$input_demo_build_k8s_cni" != "Calico" ]; then
    if [ "$input_demo_build_k8s_cni" != "Flannel" ]; then
      if [ "$input_demo_build_k8s_cni" != "Weave" ]; then
        print_warning "You didn't specify a correct K8s CNI network. Only Calico, Flannel and Weave are allowed. You specified $input_demo_build_k8s_cni"
        exit_now "You did not specify the right K8s CNI network!"
      fi
    fi
  fi

  # Check if Windows Defender should be installed.
  print_info "Windows Defender: $input_demo_build_windows_defender"
  if [ "$input_demo_build_windows_defender" == "yes" ]; then
    print_info "You specified to deploy the Windows Defender."
  else
    if [ "$input_demo_build_windows_defender" == "no" ]; then
      print_info "You specified to not deploy the Windows Defender."
    else
      print_warning "You didn't specify the windows defender configuration correct! Please specify the setting windows_defender to yes or no"        exit_now "Please use yes or no for the Windows Defender deployment configuration!"
    fi
  fi

  # Check what should happen to the temporary VM after deployment?
  print_info "Temp VM: $input_demo_temp_vm"
  if [ "$input_demo_build_temp_vm" != "suspend" ] ; then
    if [ "$input_demo_build_temp_vm" != "delete" ] ; then
      print_warning "The configuration $input_demo_build_temp_vm for temp vm is not valid. You must use suspend or delete"
      exit_now "The configuration for the temp vm is not valid!"
    else
      print_info "The configuration $input_demo_build_temp_vm for temp vm is valid"
    fi
  else
    print_info "The configuration $input_demo_build_temp_vm for temp vm is valid"
  fi
}

# check_files_and_folder will check the current files and folders for configuration, if everthing is configured as it should be.
check_files_and_folder () {
  print_info "Check the current files and folders"

  # Check for Environment configuration folder
  if [ ! -d "$demo_build_config/$input_demo_build_username-$input_demo_build_buildname" ]; then
    print_warning "The environment configuration folder $demo_build_config/$input_demo_build_username-$input_demo_build_buildname doesn't exist"
    exit_now "Make sure to run the prepare of the demo build environment"
  else
    print_info "Found the environment configuration folder $demo_build_config/$input_demo_build_username-$input_demo_build_buildname"
  fi

  # Check for files folder
  if [ ! -d "$demo_build_config/$input_demo_build_username-$input_demo_build_buildname/files" ]; then
    print_warning "The environment files folder $demo_build_config/$input_demo_build_username-$input_demo_build_buildname/files doesn't exist"
    exit_now "Make sure to run the prepare of the demo build environment"
  else
    print_info "Found the environment configuration folder $demo_build_config/$input_demo_build_username-$input_demo_build_buildname/files"
  fi

  # Check for credentials file
  if [ ! -f "$demo_build_config/$input_demo_build_username-$input_demo_build_buildname/files/$input_demo_build_username.gcp.json" ]; then
    print_warning "The credentials configuration file $demo_build_config/$input_demo_build_username-$input_demo_build_buildname/files/$input_demo_build_username.gcp.json doesn't exist"
    exit_now "Make sure to run the prepare of the demo build environment"
  else
    print_info "Found the credentials file  $demo_build_config/$input_demo_build_username-$input_demo_build_buildname/files/$input_demo_build_username.gcp.json"
  fi

  # Check for terraform state gcp folder
  if [ ! -d "$demo_build_config/$input_demo_build_username-$input_demo_build_buildname/terraform_state" ]; then
    print_warning "The terraform_state folder $demo_build_config/$input_demo_build_username-$input_demo_build_buildname/terraform_state doesn't exist"
    exit_now "Make sure to run the prepare of the demo build environment"
  else
    print_info "Found the terraform_state folder $demo_build_config/$input_demo_build_username-$input_demo_build_buildname/terraform_state"
  fi

  # Check for group_vars folder
  if [ ! -d "$demo_build_config/$input_demo_build_username-$input_demo_build_buildname/group_vars" ]; then
    print_warning "The group_vars folder $demo_build_config/$input_demo_build_username-$input_demo_build_buildname/group_vars doesn't exist"
    exit_now "Make sure to run the prepare of the demo build environment"
  else
    print_info "Found the group_vars folder $demo_build_config/$input_demo_build_username-$input_demo_build_buildname/group_vars"
  fi

  # Check ansible group vars configuration file
  if [ ! -f "$demo_build_config/$input_demo_build_username-$input_demo_build_buildname/group_vars/all.yml" ]; then
    print_warning "The ansible group vars file $demo_build_config/$input_demo_build_username-$input_demo_build_buildname/group_vars/all.yml doesn't exist"
    exit_now "Make sure to run the prepare of the demo build environment"
  else
    print_info "Found the ansible group vars file $demo_build_config/$input_demo_build_username-$input_demo_build_buildname/group_vars/all.yml"
  fi

  # Check for .ssh folder
  if [ ! -d "$demo_build_config/$input_demo_build_username-$input_demo_build_buildname/.ssh" ]; then
    print_warning "The ssh folder $demo_build_config/$input_demo_build_username-$input_demo_build_buildname/.ssh doesn't exist"
    exit_now "Make sure to run the prepare of the demo build environment"
  else
    print_info "Found the ssh folder $demo_build_config/$input_demo_build_username-$input_demo_build_buildname/.ssh"
  fi

  # Check for ssh private key
  if [ ! -f "$demo_build_config/$input_demo_build_username-$input_demo_build_buildname/.ssh/$input_demo_build_username" ]; then
    print_warning "The ssh private key $demo_build_config/$input_demo_build_username-$input_demo_build_buildname/.ssh/$input_demo_build_username doesn't exist"
    exit_now "Make sure to run the prepare of the demo build environment"
  else
    print_info "Found the ssh private key $demo_build_config/$input_demo_build_username-$input_demo_build_buildname/.ssh/$input_demo_build_username"
  fi

  # Check for ssh public key
  if [ ! -f "$demo_build_config/$input_demo_build_username-$input_demo_build_buildname/.ssh/$input_demo_build_username.pub" ]; then
    print_warning "The ssh public key $demo_build_config/$input_demo_build_username-$input_demo_build_buildname/.ssh/$input_demo_build_username.pub doesn't exist"
    exit_now "Make sure to run the prepare of the demo build environment"
  else
    print_info "Found the ssh public key $demo_build_config/$input_demo_build_username-$input_demo_build_buildname/.ssh/$input_demo_build_username.pub"
  fi

  # Check for ansible playbook configuration file
  if [ ! -f "$demo_build_config/$input_demo_build_username-$input_demo_build_buildname/inventory.yml" ]; then
    print_warning "The ansible playbook configuration file  $demo_build_config/$input_demo_build_username-$input_demo_build_buildname/inventory.yml doesn't exist"
    exit_now "Make sure to run the prepare of the demo build environment"
  else
    print_info "Found the ansible playbook configuration file $demo_build_config/$input_demo_build_username-$input_demo_build_buildname/inventory.yml"
  fi

  # Check for ansible configuration file
  if [ ! -f "$demo_build_config/$input_demo_build_username-$input_demo_build_buildname/.ansible.cfg" ]; then
    print_warning "The ansible configuration file  $demo_build_config/$input_demo_build_username-$input_demo_build_buildname/.ansible.cfg doesn't exist"
    exit_now "Make sure to run the prepare of the demo build environment"
  else
    print_info "Found the ansible configuration file $demo_build_config/$input_demo_build_username-$input_demo_build_buildname/ansible.cfg"
  fi

  # Check for terraform gcp variable configuration file
  if [ ! -f "$demo_build_config/$input_demo_build_username-$input_demo_build_buildname/variables.tf" ]; then
    print_warning "The terraform variables file $demo_build_config/$input_demo_build_username-$input_demo_build_buildname/variables.tf doesn't exist"
    exit_now "Make sure to run the prepare of the demo build environment"
  else
    print_info "Found the terraform variables file $demo_build_config/$input_demo_build_username-$input_demo_build_buildname/variables.tf"
  fi

  # Check for docker compose file
  if [ ! -f "$demo_build_config/$input_demo_build_username-$input_demo_build_buildname/docker-compose.yml" ]; then
    print_warning "The docker compose file $demo_build_config/$input_demo_build_username-$input_demo_build_buildname/docker-compose.yml doesn't exist"
    exit_now "Make sure to run the prepare of the demo build environment"
  else
    print_info "Found the docker compose file $demo_build_config/$input_demo_build_username-$input_demo_build_buildname/docker-compose.yml"
  fi
}

# prepare_deployment will prepare all necessary configurations that will be used for the deployment.
prepare_deployment () {
  print_info "Start preparing the deployment folders and files"
  # Check if the deploymentfolder already exists?
  if [ -d "$demo_build_config" ]; then
    print_info "deployment folder $demo_build_config exists."
    # Check if the template folder already existis?
    if [ ! -d "$demo_build_config/.templates" ]; then
      print_info "templates folder doesn't exist. Create it."
      mkdir "$demo_build_config/.templates" >> $deployment_log 2>&1
  		print_info "Create ansible config template file"
  		create_ansible_cfg_template
  		print_info "Create ansible all templates file"
  		create_all_template
  		print_info "Create ansible inventory template file"
      if [ "$input_demo_build_windows_defender" = "yes" ]; then
  		    create_template_inventory_with_windows
      else
          create_template_inventory_without_windows
      fi
  		print_info "Create terraform variables template file for GCP"
  		create_variables_template
  		print_info "Create docker compose template file"
      create_docker_compose_template
    else
      print_info "templates folder exist. Recreate it to get the latest and greatest"
      rm -rf "$demo_build_config/.templates" >> $deployment_log 2>&1
      mkdir "$demo_build_config/.templates" >> $deployment_log 2>&1
  		print_info "Create ansible config template file"
  		create_ansible_cfg_template
  		print_info "Create ansible all templates file"
  		create_all_template
  		print_info "Create ansible inventory template file"
      if [ "$input_demo_build_windows_defender" = "yes" ]; then
  		    create_template_inventory_with_windows
      else
          create_template_inventory_without_windows
      fi
  		print_info "Create terraform variables template file for GCP"
  		create_variables_template
  		print_info "Create docker compose template file"
      create_docker_compose_template
    fi
  else
    print_info "First deployment on this system. Create the main folder $demo_build_config"
    mkdir $demo_build_config >> $deployment_log 2>&1
		print_info "Create template folder"
		mkdir "$demo_build_config/.templates" >> $deployment_log 2>&1
		print_info "Create ansible config template file"
		create_ansible_cfg_template
		print_info "Create ansible all templates file"
		create_all_template
		print_info "Create ansible inventory template file"
    if [ "$input_demo_build_windows_defender" = "yes" ]; then
        create_template_inventory_with_windows
    else
        create_template_inventory_without_windows
    fi
		print_info "Create terraform variables template file for GCP"
		create_variables_template
		print_info "Create docker compose template file"
    create_docker_compose_template
  fi

  # Check if the environment folder already exists?
  if [ -d "$demo_build_config/$input_demo_build_username-$input_demo_build_buildname" ]; then
    print_warning "deployment folder $demo_build_config/$input_demo_build_username-$input_demo_build_buildname exists."
    exit_now "To prepare a new folder please delete the configuration with option d"
  else
    print_info "Creating the environment folder"
    mkdir $demo_build_config/$input_demo_build_username-$input_demo_build_buildname >> $deployment_log 2>&1
  fi
  mkdir "$demo_build_config/$input_demo_build_username-$input_demo_build_buildname/group_vars" >> $deployment_log 2>&1
  mkdir "$demo_build_config/$input_demo_build_username-$input_demo_build_buildname/.ssh" >> $deployment_log 2>&1
  mkdir "$demo_build_config/$input_demo_build_username-$input_demo_build_buildname/files" >> $deployment_log 2>&1
  mkdir "$demo_build_config/$input_demo_build_username-$input_demo_build_buildname/terraform_state" >> $deployment_log 2>&1

	# Copy template for Ansible
	print_info "Copy and prepare template for Ansible"
	cp "$demo_build_config/.templates/all_template.yml" "$demo_build_config/$input_demo_build_username-$input_demo_build_buildname/group_vars/all.yml" >> $deployment_log 2>&1

	# Adding License informations
	echo "twistlock_license: $demo_build_license" >> "$demo_build_config/$input_demo_build_username-$input_demo_build_buildname/group_vars/all.yml"

	# Copy credential file
	print_info "Copy credential file"
	cp "$input_demo_build_credentials_file" "$demo_build_config/$input_demo_build_username-$input_demo_build_buildname/files/$input_demo_build_username.gcp.json" >> $deployment_log 2>&1

  # Copy credential file for DNS
  if [ "$input_demo_build_credentials_file_dns" = "" ]; then
      print_info "Copy credential file for DNS $input_demo_build_credentials_file"
      cp "$input_demo_build_credentials_file" "$demo_build_config/$input_demo_build_username-$input_demo_build_buildname/files/$input_demo_build_username.dns.gcp.json" >> $deployment_log 2>&1
    else
      print_info "Copy credential file for DNS $input_demo_build_credentials_file_dns"
      cp "$input_demo_build_credentials_file_dns" "$demo_build_config/$input_demo_build_username-$input_demo_build_buildname/files/$input_demo_build_username.dns.gcp.json" >> $deployment_log 2>&1
  fi

	# Copy ssh private key
	print_info "Copy ssh private key"
	cp "$input_demo_build_ssh_private" "$demo_build_config/$input_demo_build_username-$input_demo_build_buildname/.ssh/$input_demo_build_username" >> $deployment_log 2>&1

	# Copy ssh public key
	print_info "Copy ssh public key"
	cp "$input_demo_build_ssh_public" "$demo_build_config/$input_demo_build_username-$input_demo_build_buildname/.ssh/$input_demo_build_username.pub" >> $deployment_log 2>&1

	# Copy Ansible config file
	print_info "Copy Ansible config file .ansible.cfg"
	cp "$demo_build_config/.templates/.ansible-template.cfg" "$demo_build_config/$input_demo_build_username-$input_demo_build_buildname/.ansible.cfg" >> $deployment_log 2>&1

	# Copy Ansible Inventory config file
	print_info "Copy Ansible Inventory config file"
	cp "$demo_build_config/.templates/template_inventory.yml" "$demo_build_config/$input_demo_build_username-$input_demo_build_buildname/inventory.yml" >> $deployment_log 2>&1

	# Copy Terraform Variables config file for GCP
	print_info "Copy Terraform variables config file for GCP"
	cp "$demo_build_config/.templates/variables_template.tf" "$demo_build_config/$input_demo_build_username-$input_demo_build_buildname/variables.tf" >> $deployment_log 2>&1

	# Copy Docker Compose file for this environment
	print_info "Copy Docker Compose file for this environment"
	cp "$demo_build_config/.templates/docker-compose-template.yml" "$demo_build_config/$input_demo_build_username-$input_demo_build_buildname/docker-compose.yml" >> $deployment_log 2>&1

  if [ "$input_demo_build_environment" = "cto-sandbox" ]; then
     dnsmanagedzone="lab-zone"
     dnsdomainname=".lab.twistlock.com."
     dnsextension="lab.twistlock.com"
     dnsdomainnameforstaticips="-lab-twistlock-com"
     wildcard_cert_folder="wildcard_cert"
     project_id="cto-sandbox"
     windowsimage="https:\/\/www.googleapis.com\/compute\/v1\/projects\/cto-sandbox\/global\/images\/windows2019-demo-build-v2"
  else
    if [ "$input_demo_build_environment" = "twistlock-cto-partners" ]; then
      dnsmanagedzone="partner-lab-zone"
      dnsdomainname=".p.twistlock.com."
      dnsextension="p.twistlock.com"
      dnsdomainnameforstaticips="-p-twistlock-com"
      wildcard_cert_folder="wildcard_cert_partner"
      project_id="twistlock-cto-partners"
      windowsimage="https:\/\/www.googleapis.com\/compute\/v1\/projects\/twistlock-cto-partners\/global\/images\/windows2019-demo-build-v2"
    else
        exit_now "Something is wrong with your environment configurations."
    fi
  fi

  # Check the wildcard_cert folder
  if [ -d "$demo_build_config/$wildcard_cert_folder" ]; then
      print_info "Folder for Wildcard certificates $demo_build_config/$wildcard_cert_folder exists"
  else
      print_info "Create folder for Wildcard certificates $demo_build_config/$wildcard_cert_folder"
      mkdir "$demo_build_config/$wildcard_cert_folder" >> $deployment_log 2>&1
  fi

  # Check Windows installation?
  if [ "$input_demo_build_windows_defender" = "yes" ]; then
      install_windows="true"
  else
      install_windows="false"
  fi

  # sed based on the OS
  if [ "$(uname)" = "Darwin" ]; then
    sed -i "" "s/<USERNAME>/$input_demo_build_username/g" "$demo_build_config/$input_demo_build_username-$input_demo_build_buildname/.ansible.cfg"
    if [ "$input_demo_build_environment" = "twistlock-cto-partners" ]; then
      sed -i "" "s/<DOMAINROOT>/partner/g; s/<USERNAME>/$input_demo_build_username/g; s/<PASSWORD>/$input_demo_build_password/g; s/<EMAIL>/$input_demo_build_email/g; s/<SERVICEACCOUNTEMAIL>/$input_demo_build_service_account_email/g; s/<TOKEN>/$input_demo_build_token/g; s/<K8SCNI>/$input_demo_build_k8s_cni/g; s/<DNSEXTENSION>/$dnsextension/g; s/<PROJECTID>/$project_id/g;" "$demo_build_config/$input_demo_build_username-$input_demo_build_buildname/group_vars/all.yml"
      sed -i "" "s/<USERNAME>/partner/g; s/<INSTALLVERSION>/\"$input_demo_build_twistlock_install_version\"/g; s/<BUILDNAME>/$input_demo_build_buildname/g; s/<PRERELEASEVERSION>/$input_demo_build_prerelease_version/g; s/<INSTALLPRERELEASE>/$input_demo_build_install_prerelease/g; s/<DNSEXTENSION>/$dnsextension/g;" "$demo_build_config/$input_demo_build_username-$input_demo_build_buildname/inventory.yml"
      sed -i "" "s/<USERNAME>/partner/g; s/<BUILDNAME>/$input_demo_build_buildname/g; s/<SERVICEACCOUNTEMAIL>/$input_demo_build_service_account_email/g; s/<PROJECT>/$input_demo_build_environment/g; s/<DNSMANAGEDZONE>/$dnsmanagedzone/g; s/<DNSDOMAINNAME>/$dnsdomainname/g; s/<DNSDOMAINNAMEFORSTRATICIPS>/$dnsdomainnameforstaticips/g; s/<WINVM>/$install_windows/g; s/<WINDOWSIMAGE>/$windowsimage/g;" "$demo_build_config/$input_demo_build_username-$input_demo_build_buildname/variables.tf"
    else
      sed -i "" "s/<DOMAINROOT>/$input_demo_build_username/g; s/<USERNAME>/$input_demo_build_username/g; s/<PASSWORD>/$input_demo_build_password/g; s/<EMAIL>/$input_demo_build_email/g; s/<SERVICEACCOUNTEMAIL>/$input_demo_build_service_account_email/g; s/<TOKEN>/$input_demo_build_token/g; s/<K8SCNI>/$input_demo_build_k8s_cni/g; s/<DNSEXTENSION>/$dnsextension/g; s/<PROJECTID>/$project_id/g;" "$demo_build_config/$input_demo_build_username-$input_demo_build_buildname/group_vars/all.yml"
      sed -i "" "s/<USERNAME>/$input_demo_build_username/g; s/<INSTALLVERSION>/\"$input_demo_build_twistlock_install_version\"/g; s/<BUILDNAME>/$input_demo_build_buildname/g; s/<PRERELEASEVERSION>/$input_demo_build_prerelease_version/g; s/<INSTALLPRERELEASE>/$input_demo_build_install_prerelease/g; s/<DNSEXTENSION>/$dnsextension/g;" "$demo_build_config/$input_demo_build_username-$input_demo_build_buildname/inventory.yml"
      sed -i "" "s/<USERNAME>/$input_demo_build_username/g; s/<BUILDNAME>/$input_demo_build_buildname/g; s/<SERVICEACCOUNTEMAIL>/$input_demo_build_service_account_email/g; s/<PROJECT>/$input_demo_build_environment/g; s/<DNSMANAGEDZONE>/$dnsmanagedzone/g; s/<DNSDOMAINNAME>/$dnsdomainname/g; s/<DNSDOMAINNAMEFORSTRATICIPS>/$dnsdomainnameforstaticips/g; s/<WINVM>/$install_windows/g; s/<WINDOWSIMAGE>/$windowsimage/g;" "$demo_build_config/$input_demo_build_username-$input_demo_build_buildname/variables.tf"
    fi
    sed -i "" "s/<USERNAME>/$input_demo_build_username/g; s/<BUILDNAME>/$input_demo_build_buildname/g; s/<SERVICEACCOUNTEMAIL>/$input_demo_build_service_account_email/g; s/<PROJECT>/$input_demo_build_environment/g; s/<DNSMANAGEDZONE>/$dnsmanagedzone/g; s/<DNSDOMAINNAME>/$dnsdomainname/g; s/<DNSDOMAINNAMEFORSTRATICIPS>/$dnsdomainnameforstaticips/g; s/<WINVM>/$install_windows/g; s/<WINDOWSIMAGE>/$windowsimage/g;" "$demo_build_config/$input_demo_build_username-$input_demo_build_buildname/variables.tf"
    sed -i "" "s/<USERNAME>/$input_demo_build_username/g; s/<BUILDNAME>/$input_demo_build_buildname/g; s/<WILDCARDCERT>/$wildcard_cert_folder/g; s/<GITBRANCH>/$input_demo_build_gitbranch/g;" "$demo_build_config/$input_demo_build_username-$input_demo_build_buildname/docker-compose.yml"
  else
    sed -i "s/<USERNAME>/$input_demo_build_username/g" "$demo_build_config/$input_demo_build_username-$input_demo_build_buildname/.ansible.cfg"
    if [ "$input_demo_build_environment" = "twistlock-cto-partners" ]; then
      sed -i "s/<DOMAINROOT>/partner/g; s/<USERNAME>/$input_demo_build_username/g; s/<PASSWORD>/$input_demo_build_password/g; s/<EMAIL>/$input_demo_build_email/g; s/<SERVICEACCOUNTEMAIL>/$input_demo_build_service_account_email/g; s/<TOKEN>/$input_demo_build_token/g; s/<K8SCNI>/$input_demo_build_k8s_cni/g; s/<DNSEXTENSION>/$dnsextension/g; s/<PROJECTID>/$project_id/g;" "$demo_build_config/$input_demo_build_username-$input_demo_build_buildname/group_vars/all.yml"
      sed -i "s/<USERNAME>/partner/g; s/<INSTALLVERSION>/\"$input_demo_build_twistlock_install_version\"/g; s/<BUILDNAME>/$input_demo_build_buildname/g; s/<PRERELEASEVERSION>/$input_demo_build_prerelease_version/g; s/<INSTALLPRERELEASE>/$input_demo_build_install_prerelease/g; s/<DNSEXTENSION>/$dnsextension/g;" "$demo_build_config/$input_demo_build_username-$input_demo_build_buildname/inventory.yml"
      sed -i "s/<USERNAME>/partner/g; s/<BUILDNAME>/$input_demo_build_buildname/g; s/<SERVICEACCOUNTEMAIL>/$input_demo_build_service_account_email/g; s/<PROJECT>/$input_demo_build_environment/g; s/<DNSMANAGEDZONE>/$dnsmanagedzone/g; s/<DNSDOMAINNAME>/$dnsdomainname/g; s/<DNSDOMAINNAMEFORSTRATICIPS>/$dnsdomainnameforstaticips/g; s/<WINVM>/$install_windows/g; s/<WINDOWSIMAGE>/$windowsimage/g;" "$demo_build_config/$input_demo_build_username-$input_demo_build_buildname/variables.tf"
    else
      sed -i "s/<DOMAINROOT>/$input_demo_build_username/g; s/<USERNAME>/$input_demo_build_username/g; s/<PASSWORD>/$input_demo_build_password/g; s/<EMAIL>/$input_demo_build_email/g; s/<SERVICEACCOUNTEMAIL>/$input_demo_build_service_account_email/g; s/<TOKEN>/$input_demo_build_token/g; s/<K8SCNI>/$input_demo_build_k8s_cni/g; s/<DNSEXTENSION>/$dnsextension/g; s/<PROJECTID>/$project_id/g;" "$demo_build_config/$input_demo_build_username-$input_demo_build_buildname/group_vars/all.yml"
      sed -i "s/<USERNAME>/$input_demo_build_username/g; s/<INSTALLVERSION>/\"$input_demo_build_twistlock_install_version\"/g; s/<BUILDNAME>/$input_demo_build_buildname/g; s/<PRERELEASEVERSION>/$input_demo_build_prerelease_version/g; s/<INSTALLPRERELEASE>/$input_demo_build_install_prerelease/g; s/<DNSEXTENSION>/$dnsextension/g;" "$demo_build_config/$input_demo_build_username-$input_demo_build_buildname/inventory.yml"
      sed -i "s/<USERNAME>/$input_demo_build_username/g; s/<BUILDNAME>/$input_demo_build_buildname/g; s/<SERVICEACCOUNTEMAIL>/$input_demo_build_service_account_email/g; s/<PROJECT>/$input_demo_build_environment/g; s/<DNSMANAGEDZONE>/$dnsmanagedzone/g; s/<DNSDOMAINNAME>/$dnsdomainname/g; s/<DNSDOMAINNAMEFORSTRATICIPS>/$dnsdomainnameforstaticips/g; s/<WINVM>/$install_windows/g; s/<WINDOWSIMAGE>/$windowsimage/g;" "$demo_build_config/$input_demo_build_username-$input_demo_build_buildname/variables.tf"
    fi
      sed -i "s/<USERNAME>/$input_demo_build_username/g; s/<BUILDNAME>/$input_demo_build_buildname/g; s/<WILDCARDCERT>/$wildcard_cert_folder/g; s/<GITBRANCH>/$input_demo_build_gitbranch/g;" "$demo_build_config/$input_demo_build_username-$input_demo_build_buildname/docker-compose.yml"
  fi

	# Show the tree of the folders and files
  tree -a "$demo_build_config/$input_demo_build_username-$input_demo_build_buildname"
	tree -a "$demo_build_config/$input_demo_build_username-$input_demo_build_buildname" >> $deployment_log 2>&1
}

# kill_environment is executed if you plan to destroy the environment but keep the configuration.
kill_environment (){
  print_info "Kill the current configuration"
  # Check if the environment folder already exists?
  if [ -d "$demo_build_config/$input_demo_build_username-$input_demo_build_buildname" ]; then
    print_info "Found environment folder. $demo_build_config/$input_demo_build_username-$input_demo_build_buildname"
		# Check for terraform.state file
	  if [ -f "$demo_build_config/$input_demo_build_username-$input_demo_build_buildname/terraform_state/terraform.tfstate" ]; then
      print_warning "Found terraform state. Will start to destroy the current environment"
      cd "$demo_build_config/$input_demo_build_username-$input_demo_build_buildname"
      print_info "Update the current status of the resources with the terraform_state"
      docker-compose run terraform-demo-build refresh -state=/terraform/gcp/terraform_state/terraform.tfstate /terraform/gcp/
      retVal=$?
			if [ $retVal -ne 0 ]; then
        print_warning "Error with the terraform refresh in GCP"
        exit_now "Error with terraform refresh"
      fi
      print_info "Destroy the environment"
      docker-compose run terraform-demo-build destroy -state=/terraform/gcp/terraform_state/terraform.tfstate -auto-approve /terraform/gcp/ 2>&1 | tee -a $deployment_log
      retVal=$?
      if [ $retVal -ne 0 ]; then
        print_warning "Error with the terraform destroy in GCP"
        exit_now "Error with terraform destroy"
      fi
    else
      print_warning "No terraform state found"
      exit_now "Nothing to kill"
		fi
  else
    print_warning "No environment folder $demo_build_config/$input_demo_build_username-$input_demo_build_buildname found!"
    exit_now "Nothing to kill"
  fi
}

# destroy_configuration is used if you plan to destroy the environment and the configuration.
destroy_configuration () {
  print_info "Destroy the current configuration"
  # Check if the environment folder already exists?
  if [ -d "$demo_build_config/$input_demo_build_username-$input_demo_build_buildname" ]; then
    print_info "Found environment folder. $demo_build_config/$input_demo_build_username-$input_demo_build_buildname"
		# Check for terraform.state file
	   if [ -f "$demo_build_config/$input_demo_build_username-$input_demo_build_buildname/terraform_state/terraform.tfstate" ]; then
       print_warning "Found terraform state. Will start to destroy the current environment"
       cd "$demo_build_config/$input_demo_build_username-$input_demo_build_buildname"
       print_info "Update the current status of the resources with the terraform_state"
       docker-compose run terraform-demo-build refresh -state=/terraform/gcp/terraform_state/terraform.tfstate /terraform/gcp/ 2>&1 | tee -a $deployment_log
       retVal=$?
       if [ $retVal -ne 0 ]; then
         print_warning "Error with the terraform refresh in GCP"
         exit_now "Error with terraform refresh"
       fi
			 print_info "Destroy the environment"
       docker-compose run terraform-demo-build destroy -state=/terraform/gcp/terraform_state/terraform.tfstate -auto-approve /terraform/gcp/ 2>&1 | tee -a $deployment_log
       retVal=$?
       if [ $retVal -ne 0 ]; then
         print_warning "Error with the terraform destroy in GCP"
         exit_now "Error with terraform destroy"
       fi
     else
       print_info "No terraform state found"
     fi
     print_info "Deleting the environment folders and files"
		 cd
     if [ "$(uname)" = "Darwin" ]; then
		     sudo chown -R $username:staff $demo_build_config/$input_demo_build_username-$input_demo_build_buildname/files/* 2>&1 | tee -a $deployment_log
     else
         sudo chown -R $input_demo_build_username:$input_demo_build_username $demo_build_config/$input_demo_build_username-$input_demo_build_buildname/files/* 2>&1 | tee -a $deployment_log
     fi
     rm -rf "$demo_build_config/$input_demo_build_username-$input_demo_build_buildname" 2>&1 | tee -a $deployment_log
   else
     print_warning "No environment folder $demo_build_config/$input_demo_build_username-$input_demo_build_buildname found!"
     exit_now "Nothing to delete"
   fi
}

# Build environment is used to build the environment with terraform and ansible.
build_environment () {
  print_info "Building the environment"
  # Check if there is already a terraform.state file
  if [ -f "$demo_build_config/$input_demo_build_username-$input_demo_build_buildname/terraform_state/terraform.tfstate" ]; then
    print_warning "Found terraform state. If you want to rebuild, please use the rebuild option"
    exit_now "Terraform state found. Please use option r to rebuild environment"
	else
    cd "$demo_build_config/$input_demo_build_username-$input_demo_build_buildname"
    print_info "Deploy the environment with Terraform"
    # Run the terraform deployment.
    docker-compose run terraform-demo-build apply -state=/terraform/gcp/terraform_state/terraform.tfstate -auto-approve  /terraform/gcp/ 2>&1 | tee -a $deployment_log
    # check if there are any errors detected during the terraform deployment.
    if grep -q "Error" $deployment_log; then
      print_warning "Error with the terraform deployment in GCP... Please check if GCP is healthy or if you already did deploy parts of the environment outside of Terraform"
      exit_now "Error with terraform deployment"
    else
      print_info "No errors with the terraform deployment."
    fi
    # Run the ansible deployment.
    print_info "Starting Ansible with all playbook tasks..."
    if [ "$verbose" = "yes" ]; then
        print_info "Verbose mode..."
        docker-compose run ansible-demo-build -i inventory.yml my_lab.yml -T 400 -vvvv 2>&1 | tee -a $deployment_log
    else
        docker-compose run ansible-demo-build -i inventory.yml my_lab.yml -T 400 2>&1 | tee -a $deployment_log
    fi
		retVal=$?
		if [ $retVal -ne 0 ]; then
      print_warning "Error with the ansible deployment in. Please check the error."
    	exit 1
		fi

		if [ "$input_demo_build_temp_vm" = "delete" ]; then
      print_warning "Destroy the Temp VM..."
      docker-compose run terraform-demo-build destroy -state=/terraform/gcp/terraform_state/terraform.tfstate -auto-approve -target google_compute_instance.tr -target google_compute_address.tr_static_ip /terraform/gcp/
    else
  		print_info "Leave the Temp VM in suspend state..."
		fi
  fi
}

# build_terraform is used to only build the terraform environment (no ansible)
build_terraform () {
  print_info "Building the environment (only terraform)"
  # Check if there is already a terraform.state file
  if [ -f "$demo_build_config/$input_demo_build_username-$input_demo_build_buildname/terraform_state/terraform.tfstate" ]; then
    print_warning "Found terraform state. If you want to rebuild, please use the rebuild option"
    exit_now "Terraform state found. Please use option r to rebuild environment"
	else
    cd "$demo_build_config/$input_demo_build_username-$input_demo_build_buildname"
    print_info "Deploy the environment with Terraform"
    docker-compose run terraform-demo-build apply -state=/terraform/gcp/terraform_state/terraform.tfstate -auto-approve  /terraform/gcp/ 2>&1 | tee -a $deployment_log
    if grep -q "Error" $deployment_log; then
      print_warning "Error with the terraform deployment in GCP... Please check if GCP is healthy or if you already did deploy parts of the environment outside of Terraform"
      exit_now "Error with terraform deployment"
    else
      print_info "No errors with the terraform deployment."
    fi
  fi
}

# rebuild_environment is used to rebuild the environment with the same configuration.
rebuild_environment () {
  print_info "Re-Building the environment"
  # Check if there is alread a terraform.state file
  if [ -f "$demo_build_config/$input_demo_build_username-$input_demo_build_buildname/terraform_state/terraform.tfstate" ]; then
    print_warning "Found terraform state. Will start to destroy the current environment"
    cd "$demo_build_config/$input_demo_build_username-$input_demo_build_buildname"
    print_info "Update the current status of the resources with the terraform_state"
    docker-compose run terraform-demo-build refresh -state=/terraform/gcp/terraform_state/terraform.tfstate /terraform/gcp/
    retVal=$?
    if [ $retVal -ne 0 ]; then
      print_warning "Error with the terraform refresh in GCP"
      exit_now "Error with terraform refresh"
    fi
    print_info "Destroy the environment"
    docker-compose run terraform-demo-build destroy -state=/terraform/gcp/terraform_state/terraform.tfstate -auto-approve /terraform/gcp/ 2>&1 | tee -a $deployment_log
    retVal=$?
    if [ $retVal -ne 0 ]; then
      print_warning "Error with the terraform destroy in GCP"
      exit_now "Error with terraform destroy"
    fi
    print_info "Deploy the environment with Terraform"
    docker-compose run terraform-demo-build apply -state=/terraform/gcp/terraform_state/terraform.tfstate -auto-approve  /terraform/gcp/ 2>&1 | tee -a $deployment_log
    if grep -q "Error applying plan" $deployment_log; then
      print_warning "Error with the terraform deployment in GCP... Please check if GCP is healthy or if you already did deploy parts of the environment outside of Terraform"
      exit_now "Error with terraform deployment"
    else
      print_info "No errors with the terraform deployment."
    fi
    print_info "Starting Ansible with all playbook tasks..."
    if [ "$verbose" = "yes" ]; then
        print_info "Verbose mode..."
        docker-compose run ansible-demo-build -i inventory.yml my_lab.yml -T 400 -vvvv 2>&1 | tee -a $deployment_log
    else
        docker-compose run ansible-demo-build -i inventory.yml my_lab.yml -T 400 2>&1 | tee -a $deployment_log
    fi
    retVal=$?
    if [ $retVal -ne 0 ]; then
      print_warning "Error with the ansible deployment in. Please check the error."
      exit 1
    fi
    if [ "$input_demo_build_temp_vm" = "delete" ]; then
      print_warning "Destroy the Temp VM..."
      docker-compose run terraform-demo-build destroy -state=/terraform/gcp/terraform_state/terraform.tfstate -auto-approve -target google_compute_instance.tr -target google_compute_address.tr_static_ip /terraform/gcp/
    else
      print_info "Leave the Temp VM in suspend state..."
    fi
  else
    print_warning "No terraform state found. You can only rebuild if the environment was already deployed with the demo build"
    exit_now "Terraform state not found"
	fi
}

# ansible_playbook is used to only trigger a specific ansible task or all ansible playbooks.
ansible_playbook () {
  print_info "Running ansible playbooks"
	# Check if there is already a terraform.state file
  if [ -f "$demo_build_config/$input_demo_build_username-$input_demo_build_buildname/terraform_state/terraform.tfstate" ]; then
    print_info "Found terraform state. Will start to play the ansible playbooks"
    cd "$demo_build_config/$input_demo_build_username-$input_demo_build_buildname"
    if [ "$playbook" = "all" ]; then
      print_info "Using all ansible playbooks"
      if [ "$verbose" = "yes" ]; then
        print_info "Verbose mode..."
        docker-compose run ansible-demo-build -i inventory.yml my_lab.yml -T 400 -vvvv 2>&1 | tee -a $deployment_log
      else
        docker-compose run ansible-demo-build -i inventory.yml my_lab.yml -T 400 2>&1 | tee -a $deployment_log
      fi
		else
			print_info "Start at Ansible task $playbook"
      if [ "$verbose" = "yes" ]; then
        print_info "Verbose mode..."
        docker-compose run ansible-demo-build -i inventory.yml my_lab.yml --start-at-task "$playbook" -T 400 -vvvv 2>&1 | tee -a $deployment_log
      else
        docker-compose run ansible-demo-build -i inventory.yml my_lab.yml --start-at-task "$playbook" -T 400 2>&1 | tee -a $deployment_log
      fi
		fi
    retVal=$?
    if [ $retVal -ne 0 ]; then
      print_warning "Error with the ansible deployment in. Please check the error."
      exit 1
    fi
  else
	   print_warning "No terraform state found. You can only run an ansible script on a deployed environment"
     exit_now "Terraform state not found"
	fi
}

# show_environments is used to show the current configuration files and folders for a specific environment.
show_environments () {
	if [ -d "$demo_build_config" ]; then
		print_info "Folder with Build Information exists. The following environments and files are currently available"
		tree -a "$demo_build_config"
	else
		print_info "The Folder for the Build Informations doesn't exist."
	fi
}

# create_yaml is used to create a new yaml file.
create_yaml() {
 	if [ ! -f $myyml ]; then
		print_info "Create a new demo_build.yml file"
		create_demo_build_yml
		vim $myyml
	else
		print_warning "Found existing demo_build.yml. Please remove it to be able to use this option"
		exit_now "Existing demo_build.yml"
	fi
}

# create_ansible_cfg_template is used to create a newe ansible.cfg template file.
create_ansible_cfg_template () {
cat > $demo_build_config/.templates/.ansible-template.cfg <<EOF
[defaults]
private_key_file=~/.ssh/<USERNAME>
remote_user=<USERNAME>
host_key_checking=False
log_file=/var/log/ansible.log
EOF
}

# create_all_template is used to create a new all template yml file.
create_all_template () {
cat > $demo_build_config/.templates/all_template.yml <<EOF
target_user: <USERNAME>
new_password: <PASSWORD>
emailaddr: <EMAIL>


users:
  - username: <USERNAME>
    fullname: Pierre D. Fox
    password: <PASSWORD>
    groups:
      - admins
      - devops
  - username: githubissues
    fullname: Github Issues
    password: ..generate..
    groups:
      - admins
  - username: frodo
    fullname: Frodo B. Fox
    password: ..generate..
    groups:
      - secops
  - username: ginger
    fullname: Ginger B. Fox
    password: ..generate..
    groups:
      - auditor

service_account_email: <SERVICEACCOUNTEMAIL>
credentials_file: files/<USERNAME>.gcp.json
credentials_file_dns: files/<USERNAME>.dns.gcp.json
domain_root: <DOMAINROOT>.<DNSEXTENSION>
project_id: <PROJECTID>
twistlock_registry_token: <TOKEN>
twistlock_console_k8s: true
k8s_cni_val: <K8SCNI>
EOF
}

# create_docker_compose_template is used to create the necessary docker compose template
create_docker_compose_template () {
cat > $demo_build_config/.templates/docker-compose-template.yml <<\EOF
version: '3.7'
services:
  terraform-demo-build:
    image: gcr.io/cto-sandbox/cto/terraform-demo-build:<GITBRANCH>
    container_name: terraform_demo_build
    volumes:
      - ${demo_build_config:-~/demo_build_config/<USERNAME>-<BUILDNAME>}/files/<USERNAME>.gcp.json:/terraform/gcp/twistlock-vms.json
      - ${demo_build_config:-~/demo_build_config/<USERNAME>-<BUILDNAME>}/files/<USERNAME>.dns.gcp.json:/terraform/gcp/twistlock-dns.json
      - ${demo_build_config:-~/demo_build_config/<USERNAME>-<BUILDNAME>}/variables.tf:/terraform/gcp/variables.tf
      - ${demo_build_config:-~/demo_build_config/<USERNAME>-<BUILDNAME>}/terraform_state:/terraform/gcp/terraform_state
  ansible-demo-build:
    image: gcr.io/cto-sandbox/cto/ansible-demo-build:${demo_build_tag:-<GITBRANCH>}
    container_name: demo_build
    environment:
      - DEMO_BUILD_TAG=${demo_build_tag:-<GITBRANCH>}
      - TERRAFORM=true
    volumes:
      - ${demo_build_config:-~/demo_build_config/<USERNAME>-<BUILDNAME>}/group_vars:/ansible/playbooks/group_vars
      - ${demo_build_config:-~/demo_build_config/<USERNAME>-<BUILDNAME>}/${inventory:-inventory.yml}:/ansible/playbooks/inventory.yml
      - ${demo_build_config:-~/demo_build_config/<USERNAME>-<BUILDNAME>}/files/:/ansible/playbooks/files
      - ${demo_build_config:-~/demo_build_config/<USERNAME>-<BUILDNAME>}/.ansible.cfg:/etc/ansible/ansible.cfg
      - ${demo_build_config:-~/demo_build_config/<USERNAME>-<BUILDNAME>}/.ssh:/root/.ssh
      - ${demo_build_config:-~/demo_build_config}/<WILDCARDCERT>/:/ansible/playbooks/files/wildcard_cert
      - ${prerelease:-/Volumes/GoogleDrive/Team Drives/Releases/}:/Volumes/GoogleDrive/Team Drives/Releases/
EOF
}

# create_template_inventory_without_windows is used to create a ansible inventory without a windows host.
create_template_inventory_without_windows () {
cat > $demo_build_config/.templates/template_inventory.yml <<EOF
all:
  children:
    console:
      hosts:
        master-<BUILDNAME>.<USERNAME>.<DNSEXTENSION>:
      vars:
        machine_type: n1-standard-4
        disksize: 100
        twistlock_install_version: <INSTALLVERSION>
        twistlock_direct_image_install: true
    k8s-master:
      hosts:
        master-<BUILDNAME>.<USERNAME>.<DNSEXTENSION>:
      vars:
        machine_type: n1-standard-4
        disksize: 100
        twistlock_install_version: <INSTALLVERSION>
        twistlock_direct_image_install: true
    k8s-nodes:
      hosts:
        node-<BUILDNAME>.<USERNAME>.<DNSEXTENSION>:
      vars:
        machine_type: n1-standard-2
        disksize: 10
    task-runner:
      hosts:
        temp-<BUILDNAME>.<USERNAME>.<DNSEXTENSION>:
      vars:
        machine_type: n1-standard-2
        disksize: 10
EOF
}

# create_template_inventory_with_windows is used to create a ansible inventory with a windows host.
create_template_inventory_with_windows () {
cat > $demo_build_config/.templates/template_inventory.yml <<EOF
all:
  children:
    console:
      hosts:
        master-<BUILDNAME>.<USERNAME>.<DNSEXTENSION>:
      vars:
        machine_type: n1-standard-4
        disksize: 100
        twistlock_install_version: <INSTALLVERSION>
        twistlock_direct_image_install: true
    k8s-master:
      hosts:
        master-<BUILDNAME>.<USERNAME>.<DNSEXTENSION>:
      vars:
        machine_type: n1-standard-4
        disksize: 100
        twistlock_install_version: <INSTALLVERSION>
        twistlock_direct_image_install: true
    k8s-nodes:
      hosts:
        node-<BUILDNAME>.<USERNAME>.<DNSEXTENSION>:
      vars:
        machine_type: n1-standard-2
        disksize: 10
    task-runner:
      hosts:
        temp-<BUILDNAME>.<USERNAME>.<DNSEXTENSION>:
      vars:
        machine_type: n1-standard-2
        disksize: 10
    windows:
      hosts:
        windows-<BUILDNAME>.<USERNAME>.<DNSEXTENSION>:
      vars:
        machine_type: n1-standard-2
        disksize: 100
        ansible_connection: ssh
        ansible_ssh_user: twistlock
        ansible_ssh_private_key_file: ./roles/role_windows/files/twistlock_ansible_2019
EOF
}

# create_variables_template is used to create the terraform variables file template.
create_variables_template() {
cat > $demo_build_config/.templates/variables_template.tf <<EOF
variable "name" {
  default = "<BUILDNAME>-<USERNAME>"
}

variable "username" {
  default = "<USERNAME>"
}

variable "projectname" {
  default = "<BUILDNAME>"
}

variable "project" {
  default = "<PROJECT>"
}

variable "dns-managed_zone" {
  default = "<DNSMANAGEDZONE>"
}

variable "dns-domain-name" {
  default = "<DNSDOMAINNAME>"
}

variable "dns-domain-name_for_static_ips" {
 default = "<DNSDOMAINNAMEFORSTRATICIPS>"
}

variable "service_email" {
 default = "<SERVICEACCOUNTEMAIL>"
}

variable "win_vms" {
  default = <WINVM>
}

############################
# K8s Master Configuration #
############################

variable "master_machine_type" {
  default = "n1-standard-4"
}

variable "master_boot_disk_size" {
  default = 100
}

##############################################
# K8s Linux Container Defender Configuration #
##############################################

variable "container_defender_type" {
  default = "n1-standard-2"
}

variable "container_defender_boot_disk_size" {
  default = 10
}

#######################################
# Windows Defender Node Configuration #
#######################################

variable "windowsimage" {
  default = "<WINDOWSIMAGE>"
}

variable "windows_defender_type" {
  default = "n1-standard-2"
}

variable "windows_defender_boot_disk_size" {
  default = 100
}

###################################
# Taskrunner Client Configuration #
###################################

variable "tr_boot_disk_size" {
  default = 10
}

variable "tr_machine_type" {
  default = "n1-standard-2"
}
EOF
}

# create_demo_build_yml is used to create a demo_build.yml file template.
create_demo_build_yml () {
cat > $myyml <<EOF
demo_build:
  username: batman
  buildname: test
  password: Joker
  email: batman@twistlock.com
  license: /home/batman/license.lic
  token: 47112398123098120929191
  service_account_email: batman-ansible-svc@cto-sandbox.iam.gserviceaccount.com
  credentials_file: /home/batman/mycredentials.json
  ssh_private: /home/batman/.ssh/batman
  ssh_public: /home/batman/.ssh/batman.pub
  gitbranch: latest
  environment: cto-sandbox
  twistlock_install_version: latest
  windows_defender: yes
  k8s_cni: Flannel
  temp_vm: suspend
EOF
}

# check_operatingsystem is used to check if the machine us using Linux or MacOS (Darwin) or a none supported OS
check_operatingsystem () {
  if [ "$(uname)" != "Darwin" ]; then
    if [ "$(uname)" != "Linux" ]; then
      print_warning "You are using a none supported OS. Twistlock Demo Build is only supported on MAC OS and Linux"
  		exit_now "None Supported OS used"
    else
      print_task "Running on Linux"
    fi
  else
    print_task "Running on MacOS"
  fi
}

# Starting
clear

# Logo
echo "$(tput_silent setaf 3)

████████╗██╗    ██╗██╗███████╗████████╗██╗      ██████╗  ██████╗██╗  ██╗
╚══██╔══╝██║    ██║██║██╔════╝╚══██╔══╝██║     ██╔═══██╗██╔════╝██║ ██╔╝
   ██║   ██║ █╗ ██║██║███████╗   ██║   ██║     ██║   ██║██║     █████╔╝
   ██║   ██║███╗██║██║╚════██║   ██║   ██║     ██║   ██║██║     ██╔═██╗
   ██║   ╚███╔███╔╝██║███████║   ██║   ███████╗╚██████╔╝╚██████╗██║  ██╗
   ╚═╝    ╚══╝╚══╝ ╚═╝╚══════╝   ╚═╝   ╚══════╝ ╚═════╝  ╚═════╝╚═╝  ╚═╝

 ██████╗ ███████╗███╗   ███╗ ██████╗     ██████╗ ██╗   ██╗██╗██╗     ██████╗
 ██╔══██╗██╔════╝████╗ ████║██╔═══██╗    ██╔══██╗██║   ██║██║██║     ██╔══██╗
 ██║  ██║█████╗  ██╔████╔██║██║   ██║    ██████╔╝██║   ██║██║██║     ██║  ██║
 ██║  ██║██╔══╝  ██║╚██╔╝██║██║   ██║    ██╔══██╗██║   ██║██║██║     ██║  ██║
 ██████╔╝███████╗██║ ╚═╝ ██║╚██████╔╝    ██████╔╝╚██████╔╝██║███████╗██████╔╝
 ╚═════╝ ╚══════╝╚═╝     ╚═╝ ╚═════╝     ╚═════╝  ╚═════╝ ╚═╝╚══════╝╚═════╝

$(tput_silent sgr0)"

# Change into user home directory
cd

# Check OS
check_operatingsystem

# Check for deployment log
if [ -f "$deployment_log" ]; then
  print_warning "Found existing deployment log file. Create a new one."
  rm -f $deployment_log
else
  print_info "Start with a new deployment log."
fi

# Get current date
current_date="$(date)"
print_task "$current_date" > $deployment_log

# Get current user that is executing the script.
username="$(whoami)"

# Configure the default yml file if none yml file was specified using the -f option.
myyml=~/demo_build.yml

# Check if script is executed as root and exit if that is the case.
if [ "$(id -u)" = "0" ]; then
	print_warning "$(tput_silent setaf 1)Please do not run this script with root priviliges! $(tput_silent sgr0)"
	exit 1
fi

# Chow help for all the different options you can use with the demo_build script.
show_help() {
    echo "
Usage: demo_build.sh [OPTIONS]
demo_build.sh installs and configures a Twistlock Environment based on the internal demo build.
OPTIONS:
  -a  Run only ansible playbooks. You could specify a specific one by using the name of the task or run all by specifing all as the value.
  -b  Builds the entire environment from scratch. terraform & ansible scripts.
  -c  Check for the current configuration and state of the configured VMs.
  -d  Destroys the current environment including all configuration files.
  -f  Used to specify a yml file to use instead of the default demo_build.yml
  -h  Show this help instructions
  -k  Kill the environment but leave the configuration folder and files.
  -p  Prepare the necessary files and folders.
  -r  Rebuilds an existing environment. It will delete all systems and redeploy.
  -s  Show the current existing configurations.
  -t  Run only terraform configuration.
  -y  Create a new demo_build.yml template file

"
}

# Get all the arguments used with the demo_build.sh script
args="$@"
OPTIND=1
unset name
# Check if it is an allowed option used?
optspec="h?a:bcdf:kprstvy"
while getopts "${optspec}" opt; do
    case "${opt}" in
        h)  show_help
        exit
        ;;
        a) playbook=$OPTARG
	ansible="true"
        ;;
        b) build="true"
        ;;
        c) check="true"
        ;;
        d) destroy="true"
        ;;
        f) myyml=$OPTARG
        ;;
        r) rebuild="true"
        ;;
        k) kill="true"
        ;;
        p) prepare="true"
        ;;
        s) show="true"
        ;;
        y) createyaml="true"
	      ;;
        t) terraform="true"
        ;;
        v) verbose="yes"
    esac
done

print_task "Using the YML file $myyml"

# Check if it is in verbose mode.
if [ "$verbose" = "yes" ]; then
print_warning "Running in verbose mode"
fi

# Check the current configuration.
if [ "$check" = "true" ]; then
	print_task "Check my configuration"
	check_configuration
  check_files_and_folder
  print_info "Checked the configuration and files and folder! Looks good! You are ready for deployment!"
  exit 0
fi

# Check if prepare is necessary.
if [ "$prepare" = "true" ]; then
	print_task "Prepare the environment"
	check_configuration
  prepare_deployment
  print_info "Prepared the configuration. You are ready for deployment!"
  exit 0
fi

# Check if environment should be destroyed.
if [ "$destroy" = "true" ]; then
	print_task "Destroy the environment"
	check_configuration
  destroy_configuration
  print_info "Deleted the configuration!"
  exit 0
fi

# Check if the environment should be build
if [ "$build" = "true" ]; then
	print_task "Build the environment"
	check_configuration
  check_files_and_folder
  build_environment
  print_info "Successfully deployed the environment!"
  exit 0
fi

# Check if the environment should be rebuild
if [ "$rebuild" = "true" ]; then
	print_task "Rebuild the environment"
	check_configuration
	check_files_and_folder
	rebuild_environment
	print_info "Successfully deployed the environment!"
	exit 0
fi

# Check if ansible script should be triggered
if [ "$ansible" = "true" ]; then
	print_task "Start Ansible script at task $playbook"
	check_configuration
  check_files_and_folder
  ansible_playbook
  print_info "Succesfully triggered Ansible playbook"
  exit 0
fi

# Check if only a terraform script should be triggered
if [ "$terraform" = "true" ]; then
  print_task "Deploy only the terraform resources"
  check_configuration
  check_files_and_folder
  build_terraform
  exit 0
fi

# Check if you want to see the current environment configurations
if [ "$show" = "true" ]; then
  print_task "Show the current configurations"
	show_environments
  exit 0
fi

# Check if the current environment should be killed.
if [ "$kill" = "true" ]; then
  print_task "Kill the current environment"
  check_configuration
	kill_environment
  exit 0
fi


# Check if a YAML template file should be created
if [ "$createyaml" = "true" ]; then
  print_task "Create a new default $myyml file"
  if [ ${myyml: -4} == ".yml" ]; then
    print_info "YAML file $myyml is using the right extension .yml"
  else
    print_warning 'Your YAML file is not using the right extension .yml'
   	exit_now "Make sure it is a real .yml file!"
  fi
  create_yaml
  	print_info "Created a new default $myyml file. Please edit it before preparing and build"
  exit 0
fi

