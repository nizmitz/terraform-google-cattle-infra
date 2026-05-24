locals {
  dns_private_zone_properties = { for zone in var.dns_private_zone : zone.name => {
    name   = zone.name
    domain = zone.domain
    recordsets = concat([for instance in var.vm_instances : {
      name    = instance.name
      type    = "A"
      ttl     = 3600
      records = [google_compute_instance.this[instance.name].network_interface[0].network_ip]
    }], zone.recordsets)
  } }
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
    "roles/cloudkms.cryptoKeyEncrypterDecrypter",
  ]
}
