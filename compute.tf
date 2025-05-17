################################################################################
#                                    WAF Segment                               #
################################################################################

resource "google_compute_address" "this_waf" {
  name    = "external-ip"
  project = var.project_id
  region  = var.region
}

data "google_compute_image" "this_waf" {
  family  = var.compute_configuration.os_family
  project = var.compute_configuration.os_project
}

resource "tls_private_key" "this_waf" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "google_compute_instance" "this_waf" {
  name    = var.waf_instance.name
  project = var.project_id

  zone         = "${var.region}-${var.zone}"
  machine_type = var.waf_instance.machine_type
  description  = var.waf_instance.description
  tags         = var.waf_instance.network_tags
  boot_disk {
    initialize_params {
      image = data.google_compute_image.this_waf.self_link
      size  = var.waf_instance.disk_size
    }
  }

  metadata = {
    ssh-keys = "${var.compute_configuration.ssh_user}:${tls_private_key.this_waf.public_key_openssh}"
  }

  network_interface {
    network    = google_compute_network.this.self_link
    subnetwork = google_compute_subnetwork.this.self_link
    access_config {
      nat_ip = google_compute_address.this_waf.address
    }
  }
}


################################################################################
#                                    Cattle Segment                            #
################################################################################

resource "google_compute_address" "this_cattle" {
  count   = var.cattle_instance.external_ip == true ? 1 : 0
  name    = "external-ip"
  project = var.project_id
  region  = var.region
}

data "google_compute_image" "this_cattle" {
  family  = var.compute_configuration.os_family
  project = var.compute_configuration.os_project
}

resource "tls_private_key" "this_cattle" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "google_compute_instance" "this_cattle" {
  count   = 1
  name    = var.cattle_instance.name
  project = var.project_id

  zone         = "${var.region}-${var.zone}"
  machine_type = var.cattle_instance.machine_type
  description  = var.cattle_instance.description
  tags         = var.cattle_instance.network_tags
  boot_disk {
    initialize_params {
      image = data.google_compute_image.this_cattle.self_link
      size  = var.cattle_instance.disk_size
    }
  }

  metadata = {
    ssh-keys = "${var.compute_configuration.ssh_user}:${tls_private_key.this_cattle.public_key_openssh}"
  }

  network_interface {
    network    = google_compute_network.this.self_link
    subnetwork = google_compute_subnetwork.this.self_link

  }
}
