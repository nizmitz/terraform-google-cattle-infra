locals {
  nat_ips = [for instance in var.vm_instances : instance.name if instance.nat_ip]
}
################################################################################
#                                    Cattle Segment                            #
################################################################################
resource "google_compute_address" "this" {
  for_each     = { for instance in local.nat_ips : instance => instance }
  name         = each.value
  project      = var.project_id
  region       = var.region
  address_type = "EXTERNAL"
}

data "google_compute_image" "this" {
  family  = var.compute_configuration.os_family
  project = var.compute_configuration.os_project
}

resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "google_compute_instance" "this" {
  for_each = { for instance in var.vm_instances : instance.name => instance }
  name     = each.value.name
  project  = var.project_id

  zone         = "${var.region}-${var.zone}"
  machine_type = each.value.machine_type
  description  = each.value.description
  tags         = each.value.network_tags
  boot_disk {
    initialize_params {
      image = data.google_compute_image.this.self_link
      size  = each.value.disk_size
    }
  }

  metadata = {
    ssh-keys = "${var.compute_configuration.ssh_user}:${tls_private_key.this.public_key_openssh}"
  }

  network_interface {
    network    = google_compute_network.this.self_link
    subnetwork = google_compute_subnetwork.this.self_link
    dynamic "access_config" {
      for_each = each.value.nat_ip ? [1] : []
      content {
        nat_ip = google_compute_address.this[each.value.name].address
      }
    }
  }
  allow_stopping_for_update = true
}
