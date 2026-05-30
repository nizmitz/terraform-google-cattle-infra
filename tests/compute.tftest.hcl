variables {
  project_id = "mock-project"
  region     = "asia-southeast1"
  zone       = "a"
  test_artifact_registry = [{
    name        = "mock-project-repository"
    description = "Mock docker repository"
    format      = "DOCKER"
    docker_config = [{
      immutable_tags = true
    }]
    vulnerability_scanning_config = {
      enablement_config = "INHERITED"
    }
  }]
}

run "compute_creates_service_account_and_iam" {
  command = plan

  variables {
    vm_instances     = []
    firewall_rules   = []
    dns_private_zone = []
    sql_instances    = []
  }
  assert {
    condition     = google_service_account.this.account_id == "nodes-kubernetes-sa"
    error_message = "Nodes service account must use the expected account_id."
  }

  assert {
    condition     = length(google_project_iam_member.this) == 11
    error_message = "Nodes service account must receive all kubernetes IAM roles."
  }

  assert {
    condition     = contains(keys(google_project_iam_member.this), "roles/compute.instanceAdmin")
    error_message = "Nodes service account must have compute.instanceAdmin."
  }

  assert {
    condition     = contains(keys(google_project_iam_member.this), "roles/artifactregistry.reader")
    error_message = "Nodes service account must have artifactregistry.reader."
  }
}

run "compute_skips_artifact_registry_by_default" {
  command = plan

  variables {
    vm_instances     = []
    firewall_rules   = []
    dns_private_zone = []
    sql_instances    = []
  }

  assert {
    condition     = length(google_artifact_registry_repository.this) == 0
    error_message = "No Artifact Registry repositories must be created when configuration is empty."
  }
}

run "compute_creates_artifact_registry" {
  command = plan

  variables {
    artifact_registry_configuration = var.test_artifact_registry
    vm_instances                    = []
    firewall_rules                  = []
    dns_private_zone                = []
    sql_instances                   = []
  }

  assert {
    condition     = length(google_artifact_registry_repository.this) == 1
    error_message = "One Artifact Registry repository must be created per configuration entry."
  }

  assert {
    condition     = google_artifact_registry_repository.this["mock-project-repository"].repository_id == "mock-project-repository"
    error_message = "Artifact Registry repository_id must match the configured name."
  }

  assert {
    condition     = google_artifact_registry_repository.this["mock-project-repository"].format == "DOCKER"
    error_message = "Artifact Registry repository must use the DOCKER format."
  }

  assert {
    condition     = google_artifact_registry_repository.this["mock-project-repository"].docker_config[0].immutable_tags == true
    error_message = "Artifact Registry repository must enforce immutable tags."
  }

  assert {
    condition     = google_artifact_registry_repository.this["mock-project-repository"].vulnerability_scanning_config[0].enablement_config == "INHERITED"
    error_message = "Artifact Registry vulnerability scanning must follow configuration."
  }
}

run "compute_creates_multiple_artifact_registries" {
  command = plan

  variables {
    artifact_registry_configuration = [
      var.test_artifact_registry[0],
      {
        name        = "second-repository"
        description = "Second mock repository"
        format      = "DOCKER"
        docker_config = [{
          immutable_tags = false
        }]
        vulnerability_scanning_config = {
          enablement_config = "DISABLED"
        }
      },
    ]
    vm_instances     = []
    firewall_rules   = []
    dns_private_zone = []
    sql_instances    = []
  }

  assert {
    condition     = length(google_artifact_registry_repository.this) == 2
    error_message = "One Artifact Registry repository must be created per configuration entry."
  }

  assert {
    condition     = contains(keys(google_artifact_registry_repository.this), "mock-project-repository")
    error_message = "Artifact Registry repositories must be keyed by configured name."
  }

  assert {
    condition     = contains(keys(google_artifact_registry_repository.this), "second-repository")
    error_message = "Artifact Registry repositories must be keyed by configured name."
  }
}

run "compute_creates_vm_with_encryption" {
  command = plan

  variables {
    vm_instances = [
      {
        name                   = "node-1"
        machine_type           = "n2d-standard-2"
        description            = "test node"
        network_tags           = ["k8s", "ssh"]
        disk_size              = 50
        nat_ip                 = false
        enable_disk_encryption = true
        enable_secure_boot     = true
        enable_vtpm            = true
        spot_instance          = true
        disk_type              = "pd-balanced"
        labels = [
          {
            key   = "role"
            value = "worker"
          },
        ]
      },
    ]
    firewall_rules   = []
    dns_private_zone = []
    sql_instances    = []
  }
  assert {
    condition     = length(google_compute_instance.this) == 1
    error_message = "One compute instance must be created per vm_instances entry."
  }

  assert {
    condition     = google_compute_instance.this["node-1"].machine_type == "n2d-standard-2"
    error_message = "Compute instance must use the configured machine type."
  }

  assert {
    condition     = google_compute_instance.this["node-1"].zone == "asia-southeast1-a"
    error_message = "Compute instance zone must combine region and zone."
  }

  assert {
    condition     = google_compute_instance.this["node-1"].scheduling[0].provisioning_model == "SPOT"
    error_message = "Spot instances must use the SPOT provisioning model."
  }

  assert {
    condition     = length(google_kms_key_ring.this) == 1
    error_message = "Encrypted instances must create one KMS key ring."
  }

  assert {
    condition     = google_kms_crypto_key.this["node-1"].name == "node-1-key"
    error_message = "Encrypted instances must create a per-instance KMS crypto key."
  }

  assert {
    condition     = length(google_compute_address.this) == 0
    error_message = "Instances without nat_ip must not create external addresses."
  }
}

run "compute_creates_nat_ip_when_requested" {
  command = plan

  variables {
    vm_instances = [
      {
        name                   = "node-nat"
        machine_type           = "e2-medium"
        enable_disk_encryption = true
        nat_ip                 = true
      },
    ]
    firewall_rules   = []
    dns_private_zone = []
    sql_instances    = []
  }
  assert {
    condition     = length(google_compute_address.this) == 1
    error_message = "Instances with nat_ip must create one external address."
  }

  assert {
    condition     = contains(keys(google_compute_address.this), "node-nat")
    error_message = "External address must be keyed by instance name."
  }

  assert {
    condition     = length(google_compute_instance.this["node-nat"].network_interface[0].access_config) == 1
    error_message = "Instances with nat_ip must attach an access config."
  }
}

run "compute_attaches_nodes_service_account" {
  command = plan

  variables {
    vm_instances = [
      {
        name                   = "node-1"
        machine_type           = "e2-medium"
        enable_disk_encryption = true
      },
    ]
    firewall_rules   = []
    dns_private_zone = []
    sql_instances    = []
  }
  assert {
    condition     = google_compute_instance.this["node-1"].service_account[0].email == google_service_account.this.email
    error_message = "Compute instances must use the nodes-kubernetes-sa service account."
  }

  assert {
    condition     = contains(tolist(google_compute_instance.this["node-1"].service_account[0].scopes), "https://www.googleapis.com/auth/cloud-platform")
    error_message = "Compute instances must use the cloud-platform scope."
  }
}
