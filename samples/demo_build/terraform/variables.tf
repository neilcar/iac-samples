# Default variable file that will be only used for the init of terraform during the docker build.
# The variable files used for the demo build are created with the demo_build.sh script.

variable "name" {
  default = "local-andreas"
}

variable "username" {
  default = "andreas"
}

variable "projectname" {
  default = "local"
}

variable "project" {
  default = "cto-sandbox"
}

variable "dns-managed_zone" {
  default = "lab-zone"
}

variable "dns-domain-name" {
  default = ".lab.twistlock.com."
}

variable "dns-domain-name_for_static_ips" {
  default = "-lab-twistlock-com"
}

variable "service_email" {
  default = "andreas-ansible-svc@cto-sandbox.iam.gserviceaccount.com"
}

variable "win_vms" {
  default = true
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
  default = "https://www.googleapis.com/compute/v1/projects/cto-sandbox/global/images/windows2019-demo-build-v2"
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

variable "tr_machine_type" {
  default = "n1-standard-2"
}

variable "tr_boot_disk_size" {
  default = 10
}
