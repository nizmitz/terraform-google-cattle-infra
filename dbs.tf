# ################################################################################
# #                                 Common Segment                               #
# ################################################################################

resource "random_password" "this" {
  for_each = { for instance in var.sql_instances : instance.name => instance }
  length   = 16
  special  = false
}

resource "google_sql_database_instance" "this" {
  for_each         = { for instance in var.sql_instances : instance.name => instance }
  name             = each.value.name
  region           = var.region
  project          = var.project_id
  database_version = each.value.database_version
  root_password    = random_password.this[each.value.name].result

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

    }
    insights_config {
      query_insights_enabled = each.value.query_insights_enabled
    }
  }
}
