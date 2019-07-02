variable "project_id" {}

variable "region" {
  description = "Region of resources"
}

variable "database_name_prefix" {
  description = "Prefix for the database name"
}

variable "database_version" {
  description = "Database version"
}

variable "availability_type" {
  description = "Availability type for HA"
}

variable "sql_instance_size" {
  description = "Size of Cloud SQL instances"
}

variable "sql_disk_type" {
  description = "Cloud SQL instance disk type"
}

variable "sql_disk_size" {
  description = "Storage size in GB"
}

variable "sql_require_ssl" {
  description = "Enforce SSL connections"
}

variable "sql_master_zone" {
  description = "Zone of the Cloud SQL master (a, b, ...)"
}

variable "sql_user" {
  description = "Username of the host to access the database"
}

variable "sql_pass" {
  description = "Password of the host to access the database"
}
