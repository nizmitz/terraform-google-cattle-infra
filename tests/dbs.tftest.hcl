variables {
  project_id = "mock-project"
  region     = "asia-southeast1"
  zone       = "a"
  test_sql_instance = {
    name                        = "common-postgres"
    tier                        = "db-f1-micro"
    database_version            = "POSTGRES_17"
    edition                     = "ENTERPRISE"
    availability_type           = "ZONAL"
    disk_size                   = 10
    disk_type                   = "PD_HDD"
    deletion_protection_enabled = false
    private_network             = true
    query_insights_enabled      = true
    ssl_mode                    = "ENCRYPTED_ONLY"
    database_flags              = []
  }
}

run "dbs_creates_sql_instance_with_private_network" {
  command = plan

  variables {
    sql_instances = [var.test_sql_instance]
    vm_instances  = []
    firewall_rules = []
    dns_private_zone = []
  }

  assert {
    condition     = length(google_sql_database_instance.this) == 1
    error_message = "One Cloud SQL instance must be created per sql_instances entry."
  }

  assert {
    condition     = google_sql_database_instance.this["common-postgres"].database_version == "POSTGRES_17"
    error_message = "Cloud SQL instance must use the configured database version."
  }

  assert {
    condition     = google_sql_database_instance.this["common-postgres"].region == "asia-southeast1"
    error_message = "Cloud SQL instance region must match var.region."
  }

  assert {
    condition     = google_sql_database_instance.this["common-postgres"].settings[0].tier == "db-f1-micro"
    error_message = "Cloud SQL instance must use the configured tier."
  }

  assert {
    condition     = google_sql_database_instance.this["common-postgres"].settings[0].ip_configuration[0].ipv4_enabled == false
    error_message = "Private Cloud SQL instances must disable public IPv4."
  }

  assert {
    condition     = google_sql_database_instance.this["common-postgres"].settings[0].ip_configuration[0].ssl_mode == "ENCRYPTED_ONLY"
    error_message = "Cloud SQL instance must use the configured SSL mode."
  }

  assert {
    condition     = google_sql_database_instance.this["common-postgres"].settings[0].backup_configuration[0].enabled == false
    error_message = "Cloud SQL backups must be disabled."
  }

  assert {
    condition     = google_sql_database_instance.this["common-postgres"].settings[0].password_validation_policy[0].enable_password_policy == true
    error_message = "Cloud SQL password validation policy must be enabled."
  }

  assert {
    condition     = google_sql_database_instance.this["common-postgres"].settings[0].insights_config[0].query_insights_enabled == true
    error_message = "Cloud SQL query insights must follow sql_instances configuration."
  }
}

run "dbs_creates_public_sql_when_private_network_disabled" {
  command = plan

  variables {
    sql_instances = [merge(var.test_sql_instance, { private_network = false })]
    vm_instances     = []
    firewall_rules   = []
    dns_private_zone = []
  }

  assert {
    condition     = google_sql_database_instance.this["common-postgres"].settings[0].ip_configuration[0].ipv4_enabled == true
    error_message = "Public Cloud SQL instances must enable public IPv4."
  }

  assert {
    condition     = google_sql_database_instance.this["common-postgres"].settings[0].ip_configuration[0].private_network == null
    error_message = "Public Cloud SQL instances must not attach a private network."
  }
}

run "dbs_creates_secret_manager_resources" {
  command = plan

  variables {
    sql_instances    = [var.test_sql_instance]
    vm_instances     = []
    firewall_rules   = []
    dns_private_zone = []
  }

  assert {
    condition     = length(google_secret_manager_secret.this) == 1
    error_message = "One Secret Manager secret must be created per SQL instance."
  }

  assert {
    condition     = google_secret_manager_secret.this["common-postgres"].secret_id == "common-postgres-password"
    error_message = "Secret ID must be derived from the SQL instance name."
  }

  assert {
    condition     = length(google_secret_manager_secret_version.this) == 1
    error_message = "One Secret Manager secret version must be created per SQL instance."
  }

  assert {
    condition     = length(random_password.this) == 1
    error_message = "One random password must be created per SQL instance."
  }
}
