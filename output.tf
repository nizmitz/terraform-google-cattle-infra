output "sql_properties" {
  value = {
    connection_name   = google_sql_database_instance.this.connection_name
    connection_detail = google_sql_database_instance.this.private_ip_address
  }
}

output "sql_password" {
  value     = random_password.this.result
  sensitive = true
}
