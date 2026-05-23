################################################################################
#                                Network Segment                               #
################################################################################

resource "google_compute_network" "this" {
  name                    = "${var.project_id}-vpc"
  project                 = var.project_id
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "this" {
  name          = "${var.project_id}-subnet"
  project       = var.project_id
  ip_cidr_range = element(var.network_configuration.ip_cidr_range, 0)
  region        = var.region
  network       = google_compute_network.this.self_link
}

resource "google_service_networking_connection" "this" {

  network                 = google_compute_network.this.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.this.name]
}

resource "google_compute_global_address" "this" {
  provider = google-beta

  name          = "${var.project_id}-private-ip"
  project       = var.project_id
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.this.id
}

resource "google_compute_router" "this" {
  name    = "${var.project_id}-router"
  project = var.project_id
  network = google_compute_network.this.id
}

resource "google_compute_router_nat" "this" {
  name                               = "${var.project_id}-nat"
  project                            = var.project_id
  router                             = google_compute_router.this.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  auto_network_tier                  = "STANDARD"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = google_compute_subnetwork.this.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}

################################################################################
#                                Firewall Segment                              #
################################################################################

resource "google_compute_firewall" "this" {
  for_each = { for rule in var.firewall_rules : rule.name => rule }
  name     = each.value.name
  project  = var.project_id
  network  = google_compute_network.this.self_link
  allow {
    protocol = "tcp"
    ports    = each.value.allow
  }
  target_tags   = each.value.target_tags
  source_ranges = each.value.source_ranges
}
