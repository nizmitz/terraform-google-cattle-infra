output "sql_properties" {
  value = { for instance in var.sql_instances : instance.name => {
    connection_name   = google_sql_database_instance.this[instance.name].connection_name
    connection_detail = google_sql_database_instance.this[instance.name].private_ip_address
  } }
}

output "vm_properties" {
  value = { for instance in var.vm_instances : instance.name => {
    private_ip = google_compute_instance.this[instance.name].network_interface[0].network_ip
    crypto_key = google_kms_crypto_key.this[instance.name].name
  } }
}
