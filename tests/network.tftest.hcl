variables {
  project_id = "mock-project"
  region     = "asia-southeast1"
  zone       = "a"
}

run "network_creates_vpc_and_subnet" {
  command = plan

  variables {
    network_configuration = {
      ip_cidr_range = ["172.16.0.0/16"]
    }
    vm_instances     = []
    firewall_rules   = []
    dns_private_zone = []
    sql_instances    = []
  }
  assert {
    condition     = google_compute_network.this.name == "mock-project-vpc"
    error_message = "VPC name must be derived from project_id."
  }

  assert {
    condition     = google_compute_network.this.auto_create_subnetworks == false
    error_message = "VPC must not auto-create subnetworks."
  }

  assert {
    condition     = google_compute_subnetwork.this.ip_cidr_range == "172.16.0.0/16"
    error_message = "Subnet must use the first CIDR from network_configuration."
  }

  assert {
    condition     = google_compute_subnetwork.this.region == "asia-southeast1"
    error_message = "Subnet region must match var.region."
  }
}

run "network_nat_defaults_to_auto_allocation" {
  command = plan

  variables {
    nat_configuration = {}
    vm_instances      = []
    firewall_rules    = []
    dns_private_zone  = []
    sql_instances     = []
  }
  assert {
    condition     = google_compute_router_nat.this.nat_ip_allocate_option == "AUTO_ONLY"
    error_message = "NAT must use AUTO_ONLY when dynamic port allocation is disabled."
  }

  assert {
    condition     = google_compute_router_nat.this.initial_nat_ips == null
    error_message = "NAT must not reserve static IPs when dynamic port allocation is disabled."
  }

  assert {
    condition     = google_compute_router_nat.this.enable_dynamic_port_allocation == false
    error_message = "Dynamic port allocation must be disabled by default."
  }
}

run "network_nat_manual_allocation_when_enabled" {
  command = plan

  variables {
    nat_configuration = {
      network_tier                   = "PREMIUM"
      enable_dynamic_port_allocation = true
    }
    vm_instances     = []
    firewall_rules   = []
    dns_private_zone = []
    sql_instances    = []
  }
  assert {
    condition     = google_compute_router_nat.this.nat_ip_allocate_option == "MANUAL_ONLY"
    error_message = "NAT must use MANUAL_ONLY when dynamic port allocation is enabled."
  }

  assert {
    condition     = google_compute_router_nat.this.enable_dynamic_port_allocation == true
    error_message = "Dynamic port allocation must be enabled when configured."
  }

  assert {
    condition     = google_compute_address.this_nat.name == "mock-project-nat-ip"
    error_message = "NAT must reserve a dedicated external IP when dynamic port allocation is enabled."
  }

  assert {
    condition     = google_compute_address.this_nat.network_tier == "PREMIUM"
    error_message = "NAT address network tier must match nat_configuration."
  }
}

run "network_creates_firewall_rules" {
  command = plan

  variables {
    firewall_rules = [
      {
        name          = "allow-ssh"
        source_ranges = ["172.16.0.0/16"]
        target_tags   = ["ssh"]
        allow         = ["22"]
        protocol      = "tcp"
      },
      {
        name          = "allow-ping"
        source_ranges = ["0.0.0.0/0"]
        target_tags   = ["ping"]
        protocol      = "icmp"
      },
    ]
    vm_instances     = []
    dns_private_zone = []
    sql_instances    = []
  }
  assert {
    condition     = length(google_compute_firewall.this) == 2
    error_message = "One firewall resource must be created per firewall rule."
  }

  assert {
    condition     = google_compute_firewall.this["allow-ssh"].name == "allow-ssh"
    error_message = "Firewall rules must be keyed by rule name."
  }

  assert {
    condition     = contains(tolist(tolist(google_compute_firewall.this["allow-ssh"].allow)[0].ports), "22")
    error_message = "SSH firewall rule must allow port 22."
  }

  assert {
    condition     = tolist(google_compute_firewall.this["allow-ping"].allow)[0].protocol == "icmp"
    error_message = "Ping firewall rule must use the icmp protocol."
  }
}

run "network_private_service_connection" {
  command = plan

  variables {
    vm_instances     = []
    firewall_rules   = []
    dns_private_zone = []
    sql_instances    = []
  }
  assert {
    condition     = google_compute_global_address.this.purpose == "VPC_PEERING"
    error_message = "Global address must be reserved for VPC peering."
  }

  assert {
    condition     = google_compute_global_address.this.prefix_length == 16
    error_message = "Private service connection must reserve a /16 range."
  }

  assert {
    condition     = google_service_networking_connection.this.service == "servicenetworking.googleapis.com"
    error_message = "Service networking connection must target servicenetworking.googleapis.com."
  }
}
