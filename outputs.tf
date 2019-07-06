# cloud SQL postgresql outputs

output "master_instance_sql_ipv4" {
  value       = "${google_sql_database_instance.master.ip_address.0.ip_address}"
  description = "The IPv4 address assigned for master"
}

output "master_instance_sql_name" {
  value       = "${google_sql_database_instance.master.name}"
  description = "The database name for master"
}

output "master_private_ip" {
  description = "The private IPv4 address of the master instance"
  value       = "${google_sql_database_instance.master.private_ip_address}"
}

output "master_instance" {
  description = "Self link to the master instance"
  value       = "${google_sql_database_instance.master.self_link}"
}

output "master_ip_addresses" {
  description = "All IP addresses of the master instance JSON encoded, see https://www.terraform.io/docs/providers/google/r/sql_database_instance.html#ip_address-0-ip_address"
  value       = "${jsonencode(google_sql_database_instance.master.ip_address)}"
}

output "dependency_id" {
  value = "${join("/", list(google_sql_database_instance.master.name,google_sql_user.user.name,google_sql_database.google_sql_database.name,google_sql_database_instance.master.private_ip_address,google_sql_database_instance.master.ip_address.0.ip_address))}"
}
