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
  ip_cidr_range = var.ip_cidr_range[0]
  region        = var.region
  network       = google_compute_network.this.self_link
}

################################################################################
#                                Firewall Segment                              #
################################################################################

resource "google_compute_firewall" "this_ssh_external" {
  name    = "allow-ssh"
  project = var.project_id
  network = google_compute_network.this.self_link
  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags   = ["waf"]
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "this_all_internal" {
  name    = "allow-internal"
  project = var.project_id
  network = google_compute_network.this.self_link
  allow {
    protocol = "all"
  }

  target_tags   = ["internal"]
  source_ranges = var.ip_cidr_range
}
