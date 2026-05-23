output "sql_properties" {
  value = { for instance in var.sql_instances : instance.name => {
    connection_name   = google_sql_database_instance.this[instance.name].connection_name
    connection_detail = google_sql_database_instance.this[instance.name].private_ip_address
  } }
}
