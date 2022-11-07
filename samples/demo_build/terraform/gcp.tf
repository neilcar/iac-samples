# Google Cloud Terraform template.
# Created by: Andreas Wilke
# This Terraform file is used to create all the necessary resources for the demo build inside the Google Cloud platform (GCP)

# Google Provider used for the VMs to create. It can have cto-sandbox or any other supported GCP Project.
provider "google" {
  alias       = "vms"
  credentials = "${file("/terraform/gcp/twistlock-vms.json")}"
  project     = "${var.project}"
  region      = "us-central1"
  zone        = "us-central1-a"
}

# Google Provider used for the DNS entries. Currently they are all managed inside the cto-sandbox project.
provider "google" {
  alias       = "dns"
  credentials = "${file("/terraform/gcp/twistlock-dns.json")}"
  project     = "cto-sandbox"
  region      = "us-central1"
  zone        = "us-central1-a"
}

# Master VM Configurations

# Master VM static IP configurations
resource "google_compute_address" "master_static_ip" {
  provider     = google.vms
  name         = "master-${var.projectname}-${var.username}${var.dns-domain-name_for_static_ips}"
  address_type = "EXTERNAL"
}

# Master VM google_compute_instance configuration
resource "google_compute_instance" "master" {
  provider     = google.vms
  name         = "master-${var.projectname}-${var.username}${var.dns-domain-name_for_static_ips}"
  machine_type = "${var.master_machine_type}"

  boot_disk {
    initialize_params {
      image = "demo-build"
      size  = "${var.master_boot_disk_size}"
    }
  }

  labels = {
    owner     = "${var.username}"
    createdby = "demo_build_with_terraform"
  }

  network_interface {
    network = "default"

    access_config {
      nat_ip = "${google_compute_address.master_static_ip.address}"
    }
  }

  service_account {
    email  = "${var.service_email}"
    scopes = ["cloud-platform", "storage-full"]
  }
}

# Container Defender Configurations

# Container Defender static IP configurations
resource "google_compute_address" "container_defender_static_ip" {
  provider     = google.vms
  name         = "node-${var.projectname}-${var.username}${var.dns-domain-name_for_static_ips}"
  address_type = "EXTERNAL"
}

# Container Defender google_compute_instance configurations
resource "google_compute_instance" "container_defender" {
  provider     = google.vms
  name         = "node-${var.projectname}-${var.username}${var.dns-domain-name_for_static_ips}"
  machine_type = "${var.container_defender_type}"

  boot_disk {
    initialize_params {
      image = "demo-build"
      size  = "${var.container_defender_boot_disk_size}"
    }
  }

  labels = {
    owner     = "${var.username}"
    createdby = "demo_build_with_terraform"
  }

  network_interface {
    network = "default"

    access_config {
      nat_ip = "${google_compute_address.container_defender_static_ip.address}"
    }
  }

  service_account {
    email  = "${var.service_email}"
    scopes = ["cloud-platform", "storage-full"]
  }
}

# Windows defender configuration

# Windows Defender static IP configurations
resource "google_compute_address" "windows_defender_static_ip" {
  provider     = google.vms
  count        = "${var.win_vms ? 1 : 0}"
  name         = "windows-${var.projectname}-${var.username}${var.dns-domain-name_for_static_ips}"
  address_type = "EXTERNAL"
}

# Container Defender google_compute_instance configurations
resource "google_compute_instance" "windows_defender" {
  provider     = google.vms
  count        = "${var.win_vms ? 1 : 0}"
  name         = "windows-${var.projectname}-${var.username}${var.dns-domain-name_for_static_ips}"
  machine_type = "${var.windows_defender_type}"

  boot_disk {
    initialize_params {
      image = "${var.windowsimage}"
      size  = "${var.windows_defender_boot_disk_size}"
    }
  }

  labels = {
    owner     = "${var.username}"
    createdby = "demo_build_with_terraform"
  }

  network_interface {
    network = "default"

    access_config {
      nat_ip = "${google_compute_address.windows_defender_static_ip[0].address}"
    }
  }

  service_account {
    email  = "${var.service_email}"
    scopes = ["cloud-platform", "storage-full"]
  }
}

# Task Runner Client

# Task Runner static IP configurations
resource "google_compute_address" "tr_static_ip" {
  provider     = google.vms
  name         = "temp-${var.projectname}-${var.username}${var.dns-domain-name_for_static_ips}"
  address_type = "EXTERNAL"
}

# Task runner google_compute_instance configurations
resource "google_compute_instance" "tr" {
  provider     = google.vms
  name         = "temp-${var.projectname}-${var.username}${var.dns-domain-name_for_static_ips}"
  machine_type = "${var.tr_machine_type}"

  boot_disk {
    initialize_params {
      image = "demo-build"
      size  = "${var.tr_boot_disk_size}"
    }
  }

  labels = {
    owner     = "${var.username}"
    createdby = "demo_build_with_terraform"
  }

  network_interface {
    network = "default"

    access_config {
      nat_ip = "${google_compute_address.tr_static_ip.address}"
    }
  }

  service_account {
    email  = "${var.service_email}"
    scopes = ["cloud-platform", "storage-full"]
  }
}

# Master DNS Entries

# DNS Entry for external IP of the Master
resource "google_dns_record_set" "master" {
  provider = google.dns
  name     = "master-${var.projectname}.${var.username}${var.dns-domain-name}"
  type     = "A"
  ttl      = 60

  managed_zone = "${var.dns-managed_zone}"

  rrdatas = ["${google_compute_address.master_static_ip.address}"]
}

# Wildcard DNS Entry for the external IP of the master
resource "google_dns_record_set" "wildcard" {
  provider = google.dns
  name     = "*.master-${var.projectname}.${var.username}${var.dns-domain-name}"
  type     = "CNAME"
  ttl      = 60

  managed_zone = "${var.dns-managed_zone}"

  rrdatas = ["master-${var.projectname}.${var.username}${var.dns-domain-name}"]
}

# console DNS Entry for the external IP of the master
resource "google_dns_record_set" "console" {
  provider = google.dns
  name     = "console-master-${var.projectname}.${var.username}${var.dns-domain-name}"
  type     = "CNAME"
  ttl      = 60

  managed_zone = "${var.dns-managed_zone}"

  rrdatas = ["master-${var.projectname}.${var.username}${var.dns-domain-name}"]
}

# harbor DNS Entry for the external IP of the master
resource "google_dns_record_set" "harbor" {
  provider = google.dns
  name     = "harbor-master-${var.projectname}.${var.username}${var.dns-domain-name}"
  type     = "CNAME"
  ttl      = 60

  managed_zone = "${var.dns-managed_zone}"

  rrdatas = ["master-${var.projectname}.${var.username}${var.dns-domain-name}"]
}

# notary/harbor DNS Entry for the external IP of the master
resource "google_dns_record_set" "notary" {
  provider = google.dns
  name     = "notary-master-${var.projectname}.${var.username}${var.dns-domain-name}"
  type     = "CNAME"
  ttl      = 60

  managed_zone = "${var.dns-managed_zone}"

  rrdatas = ["master-${var.projectname}.${var.username}${var.dns-domain-name}"]
}

# mail DNS Entry for the external IP of the master
resource "google_dns_record_set" "mail" {
  provider = google.dns
  name     = "mail-master-${var.projectname}.${var.username}${var.dns-domain-name}"
  type     = "CNAME"
  ttl      = 60

  managed_zone = "${var.dns-managed_zone}"

  rrdatas = ["master-${var.projectname}.${var.username}${var.dns-domain-name}"]
}

# jenkins DNS Entry for the external IP of the master
resource "google_dns_record_set" "jenkins" {
  provider = google.dns
  name     = "jenkins-master-${var.projectname}.${var.username}${var.dns-domain-name}"
  type     = "CNAME"
  ttl      = 60

  managed_zone = "${var.dns-managed_zone}"

  rrdatas = ["master-${var.projectname}.${var.username}${var.dns-domain-name}"]
}

# splunk DNS Entry for the external IP of the master
resource "google_dns_record_set" "splunk" {
  provider = google.dns
  name     = "splunk-master-${var.projectname}.${var.username}${var.dns-domain-name}"
  type     = "CNAME"
  ttl      = 60

  managed_zone = "${var.dns-managed_zone}"

  rrdatas = ["master-${var.projectname}.${var.username}${var.dns-domain-name}"]
}

# k8s DNS Entry for the external IP of the master
resource "google_dns_record_set" "k8s" {
  provider = google.dns
  name     = "K8s-master-${var.projectname}.${var.username}${var.dns-domain-name}"
  type     = "CNAME"
  ttl      = 60

  managed_zone = "${var.dns-managed_zone}"

  rrdatas = ["master-${var.projectname}.${var.username}${var.dns-domain-name}"]
}

# sockshop DNS Entry for the external IP of the master
resource "google_dns_record_set" "sockshop" {
  provider = google.dns
  name     = "sockshop-master-${var.projectname}.${var.username}${var.dns-domain-name}"
  type     = "CNAME"
  ttl      = 60

  managed_zone = "${var.dns-managed_zone}"

  rrdatas = ["master-${var.projectname}.${var.username}${var.dns-domain-name}"]
}

# defender DNS Entry for the external IP of the master
resource "google_dns_record_set" "defender" {
  provider = google.dns
  name     = "defender-master-${var.projectname}.${var.username}${var.dns-domain-name}"
  type     = "CNAME"
  ttl      = 60

  managed_zone = "${var.dns-managed_zone}"

  rrdatas = ["master-${var.projectname}.${var.username}${var.dns-domain-name}"]
}

# phpdemo DNS Entry for the external IP of the master
resource "google_dns_record_set" "phpdemo" {
  provider = google.dns
  name     = "phpdemo-master-${var.projectname}.${var.username}${var.dns-domain-name}"
  type     = "CNAME"
  ttl      = 60

  managed_zone = "${var.dns-managed_zone}"

  rrdatas = ["master-${var.projectname}.${var.username}${var.dns-domain-name}"]
}

# dvwa DNS Entry for the external IP of the master
resource "google_dns_record_set" "dvwa" {
  provider = google.dns
  name     = "dvwa-master-${var.projectname}.${var.username}${var.dns-domain-name}"
  type     = "CNAME"
  ttl      = 60

  managed_zone = "${var.dns-managed_zone}"

  rrdatas = ["master-${var.projectname}.${var.username}${var.dns-domain-name}"]
}

# gogs DNS Entry for the external IP of the master
resource "google_dns_record_set" "gogs" {
  provider = google.dns
  name     = "gogs-master-${var.projectname}.${var.username}${var.dns-domain-name}"
  type     = "CNAME"
  ttl      = 60

  managed_zone = "${var.dns-managed_zone}"

  rrdatas = ["master-${var.projectname}.${var.username}${var.dns-domain-name}"]
}

# Container Defender DNS Entry

resource "google_dns_record_set" "container_defender" {
  provider = google.dns
  name     = "node-${var.projectname}.${var.username}${var.dns-domain-name}"
  type     = "A"
  ttl      = 60

  managed_zone = "${var.dns-managed_zone}"

  rrdatas = ["${google_compute_address.container_defender_static_ip.address}"]
}

# Windows defender DNS Entry

resource "google_dns_record_set" "windows_defender" {
  provider = google.dns
  count    = "${var.win_vms ? 1 : 0}"
  name     = "windows-${var.projectname}.${var.username}${var.dns-domain-name}"
  type     = "A"
  ttl      = 60

  managed_zone = "${var.dns-managed_zone}"

  rrdatas = ["${google_compute_address.windows_defender_static_ip[0].address}"]
}

# Task Runner Client DNS Entry

resource "google_dns_record_set" "tr" {
  provider = google.dns
  name     = "temp-${var.projectname}.${var.username}${var.dns-domain-name}"
  type     = "A"
  ttl      = 60

  managed_zone = "${var.dns-managed_zone}"

  rrdatas = ["${google_compute_address.tr_static_ip.address}"]
}
