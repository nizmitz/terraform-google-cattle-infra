################################################################################
#                                 Common Segment                               #
################################################################################

resource "random_password" "this" {
  length  = 16
  special = false
}

resource "google_sql_database_instance" "this" {
  name             = var.sql_instance.name
  region           = var.region
  project          = var.project_id
  database_version = var.sql_instance.database_version
  root_password    = random_password.this.result

  settings {
    tier                        = var.sql_instance.tier
    edition                     = var.sql_instance.edition
    availability_type           = var.sql_instance.availability_type
    disk_size                   = var.sql_instance.disk_size
    disk_type                   = var.sql_instance.disk_type
    deletion_protection_enabled = var.sql_instance.deletion_protection_enabled
    backup_configuration {
      enabled = false
    }
    ip_configuration {
      ipv4_enabled    = var.sql_instance.private_network == true ? false : true
      private_network = var.sql_instance.private_network == true ? google_compute_network.this.self_link : null

    }
    insights_config {
      query_insights_enabled = var.sql_instance.query_insights_enabled
    }
  }
}
