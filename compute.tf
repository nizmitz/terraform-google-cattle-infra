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
  for_each = { for instance in var.vm_instances : instance.name => instance }
  family   = each.value.os_family
  project  = each.value.os_project
}

resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "google_kms_key_ring" "this" {
  for_each = { for instance in var.vm_instances : instance.name => instance if instance.enable_disk_encryption }
  name     = "${each.value.name}-key-ring"
  location = var.region
  project  = var.project_id
}

resource "google_kms_crypto_key" "this" {
  for_each        = { for instance in var.vm_instances : instance.name => instance if instance.enable_disk_encryption }
  name            = "${each.value.name}-key"
  key_ring        = google_kms_key_ring.this[each.value.name].id
  rotation_period = "7776000s"
  purpose         = "ENCRYPT_DECRYPT"
  version_template {
    algorithm        = "GOOGLE_SYMMETRIC_ENCRYPTION"
    protection_level = "SOFTWARE"
  }
}

resource "google_compute_instance" "this" {
  for_each = { for instance in var.vm_instances : instance.name => instance }
  name     = each.value.name
  project  = var.project_id

  zone         = "${var.region}-${var.zone}"
  machine_type = each.value.machine_type
  description  = each.value.description
  tags         = each.value.network_tags
  labels       = { for label in each.value.labels : label.key => label.value }
  boot_disk {
    initialize_params {
      image = data.google_compute_image.this[each.value.name].self_link
      size  = each.value.disk_size
      type  = each.value.disk_type
    }
    kms_key_self_link               = each.value.enable_disk_encryption ? google_kms_crypto_key.this[each.value.name].id : null
    disk_encryption_service_account = each.value.enable_disk_encryption ? google_service_account.this.email : null
  }

  metadata = {
    enable-oslogin = each.value.enable_oslogin ? "TRUE" : "FALSE"
    ssh-keys       = "${each.value.ssh_user}:${tls_private_key.this.public_key_openssh}"
  }

  scheduling {
    preemptible                 = each.value.spot_instance ? true : false
    automatic_restart           = !each.value.spot_instance ? true : false
    provisioning_model          = each.value.spot_instance ? "SPOT" : "STANDARD"
    instance_termination_action = each.value.spot_instance ? "STOP" : "DELETE"
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
  shielded_instance_config {
    enable_secure_boot          = each.value.enable_secure_boot
    enable_vtpm                 = each.value.enable_vtpm
    enable_integrity_monitoring = each.value.enable_integrity_monitoring
  }
}

################################################################################
#                                    Gar Segment                              #
################################################################################

resource "google_artifact_registry_repository" "this" {
  for_each      = { for repository in var.artifact_registry_configuration : repository.name => repository }
  repository_id = each.value.name
  project       = var.project_id
  location      = var.region
  format        = each.value.format
  description   = each.value.description
  docker_config {
    immutable_tags = each.value.docker_config[0].immutable_tags
  }
  vulnerability_scanning_config {
    enablement_config = each.value.vulnerability_scanning_config.enablement_config
  }
}
