mock_provider "google" {
  mock_data "google_compute_image" {
    defaults = {
      self_link = "https://www.googleapis.com/compute/v1/projects/debian-cloud/global/images/debian-12-mock"
      family    = "debian-12"
    }
  }

  mock_resource "google_compute_network" {
    defaults = {
      id        = "projects/mock-project/global/networks/mock-vpc"
      self_link = "https://www.googleapis.com/compute/v1/projects/mock-project/global/networks/mock-vpc"
      name      = "mock-vpc"
    }
  }

  mock_resource "google_compute_subnetwork" {
    defaults = {
      id        = "projects/mock-project/regions/asia-southeast1/subnetworks/mock-subnet"
      self_link = "https://www.googleapis.com/compute/v1/projects/mock-project/regions/asia-southeast1/subnetworks/mock-subnet"
    }
  }

  mock_resource "google_service_networking_connection" {
    defaults = {
      id = "projects/mock-project/global/networks/mock-vpc:servicenetworking.googleapis.com"
    }
  }

  mock_resource "google_compute_router" {
    defaults = {
      id   = "projects/mock-project/regions/asia-southeast1/routers/mock-router"
      name = "mock-router"
    }
  }

  mock_resource "google_compute_address" {
    defaults = {
      id      = "projects/mock-project/regions/asia-southeast1/addresses/mock-address"
      address = "203.0.113.10"
    }
  }

  mock_resource "google_compute_router_nat" {
    defaults = {
      id = "projects/mock-project/regions/asia-southeast1/routers/mock-router/nats/mock-nat"
    }
  }

  mock_resource "google_compute_firewall" {
    defaults = {
      id = "projects/mock-project/global/firewalls/mock-firewall"
    }
  }

  mock_resource "google_service_account" {
    defaults = {
      id    = "projects/mock-project/serviceAccounts/nodes-kubernetes-sa@mock-project.iam.gserviceaccount.com"
      email = "nodes-kubernetes-sa@mock-project.iam.gserviceaccount.com"
    }
  }

  mock_resource "google_project_iam_member" {
    defaults = {
      id = "mock-project/roles/compute.viewer/serviceAccount:nodes-kubernetes-sa@mock-project.iam.gserviceaccount.com"
    }
  }

  mock_resource "google_kms_key_ring" {
    defaults = {
      id = "projects/mock-project/locations/asia-southeast1/keyRings/mock-key-ring"
    }
  }

  mock_resource "google_kms_crypto_key" {
    defaults = {
      id   = "projects/mock-project/locations/asia-southeast1/keyRings/mock-key-ring/cryptoKeys/mock-key"
      name = "mock-key"
    }
  }

  mock_resource "google_compute_instance" {
    defaults = {
      id = "projects/mock-project/zones/asia-southeast1-a/instances/mock-instance"
      network_interface = [{
        network_ip = "172.16.0.10"
      }]
    }
  }

  mock_resource "google_artifact_registry_repository" {
    defaults = {
      id = "projects/mock-project/locations/asia-southeast1/repositories/mock-repository"
    }
  }

  mock_resource "google_secret_manager_secret" {
    defaults = {
      id        = "projects/mock-project/secrets/mock-secret"
      secret_id = "mock-secret"
    }
  }

  mock_resource "google_secret_manager_secret_version" {
    defaults = {
      id     = "projects/mock-project/secrets/mock-secret/versions/1"
      secret = "projects/mock-project/secrets/mock-secret"
    }
  }

  mock_resource "google_sql_database_instance" {
    defaults = {
      id              = "mock-project:asia-southeast1:mock-sql"
      connection_name = "mock-project:asia-southeast1:mock-sql"
      name            = "mock-sql"
    }
  }

  mock_resource "google_dns_managed_zone" {
    defaults = {
      id       = "projects/mock-project/managedZones/mock-zone"
      name     = "mock-zone"
      dns_name = "example.com."
    }
  }

  mock_resource "google_dns_record_set" {
    defaults = {
      id = "projects/mock-project/managedZones/mock-zone/rrsets/mock.example.com./A"
    }
  }
}

mock_provider "google-beta" {
  mock_resource "google_compute_global_address" {
    defaults = {
      id   = "projects/mock-project/global/addresses/mock-private-ip"
      name = "mock-private-ip"
    }
  }
}
