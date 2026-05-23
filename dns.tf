module "dns-private-zone" {
  for_each   = { for zone in var.dns_private_zone : zone.name => zone }
  source     = "terraform-google-modules/cloud-dns/google"
  version    = "~> 7.0"
  project_id = var.project_id
  type       = "private"
  name       = each.value.name
  domain     = each.value.domain

  private_visibility_config_networks = [
    google_compute_network.this.self_link
  ]

  recordsets = each.value.recordsets
}
