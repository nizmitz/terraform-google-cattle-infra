# ################################################################################
# #                                 Common Segment                               #
# ################################################################################

resource "random_password" "this" {
  for_each = { for instance in var.sql_instances : instance.name => instance }
  length   = 16
  special  = false
}

resource "google_secret_manager_secret" "this" {
  for_each  = { for instance in var.sql_instances : instance.name => instance }
  secret_id = "${each.value.name}-password"
  project   = var.project_id
  replication {
    auto {}
  }
}

ephemeral "random_password" "this" {
  for_each         = { for instance in var.sql_instances : instance.name => instance }
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "google_secret_manager_secret_version" "this" {
  for_each               = { for instance in var.sql_instances : instance.name => instance }
  secret                 = google_secret_manager_secret.this[each.value.name].id
  secret_data_wo_version = 1
  secret_data_wo         = ephemeral.random_password.this[each.value.name].result
}

resource "google_sql_database_instance" "this" {
  for_each                 = { for instance in var.sql_instances : instance.name => instance }
  name                     = each.value.name
  region                   = var.region
  project                  = var.project_id
  database_version         = each.value.database_version
  root_password_wo         = ephemeral.random_password.this[each.value.name].result
  root_password_wo_version = 1

  settings {
    tier                        = each.value.tier
    edition                     = each.value.edition
    availability_type           = each.value.availability_type
    disk_size                   = each.value.disk_size
    disk_type                   = each.value.disk_type
    deletion_protection_enabled = each.value.deletion_protection_enabled
    backup_configuration {
      enabled = false
    }
    ip_configuration {
      ipv4_enabled    = each.value.private_network == true ? false : true
      private_network = each.value.private_network == true ? google_compute_network.this.self_link : null
      ssl_mode        = each.value.ssl_mode

    }
    password_validation_policy {
      min_length                  = 8
      complexity                  = "COMPLEXITY_DEFAULT"
      reuse_interval              = 2
      disallow_username_substring = true
      enable_password_policy      = true
    }
    insights_config {
      query_insights_enabled = each.value.query_insights_enabled
    }
  }
}
