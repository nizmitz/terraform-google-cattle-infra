locals {
  nat_ips = [for instance in var.vm_instances : instance.name if instance.nat_ip]
  kubernetes_roles = [
    "roles/compute.instanceAdmin",
    "roles/compute.networkAdmin",
    "roles/compute.securityAdmin",
    "roles/compute.storageAdmin",
    "roles/compute.viewer",
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/secretmanager.secretAccessor",
    "roles/cloudsql.client",
    "roles/artifactregistry.reader",
  ]
}
################################################################################
#                                    Nodes Segment                            #
################################################################################
resource "google_compute_address" "this" {
  for_each     = { for instance in local.nat_ips : instance => instance }
  name         = each.value
  project      = var.project_id
  region       = var.region
  address_type = "EXTERNAL"
}

resource "google_service_account" "this" {
  project      = var.project_id
  account_id   = "nodes-kubernetes-sa"
  display_name = "Nodes Kubernetes Service Account"
}

resource "google_project_iam_member" "this" {
  for_each = { for role in local.kubernetes_roles : role => role }
  project  = var.project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.this.email}"
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
  service_account {
    email  = google_service_account.this.email
    scopes = ["cloud-platform"]
  }
}

################################################################################
#                                    Gar Segment                              #
################################################################################




resource "google_artifact_registry_repository" "this" {
  repository_id = "${var.project_id}-repository"
  project       = var.project_id
  location      = var.region
  format        = "DOCKER"
  description   = "Docker repository for the project"
  docker_config {
    immutable_tags = true
  }

}
