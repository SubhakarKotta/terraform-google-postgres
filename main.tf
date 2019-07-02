provider "random" {}

resource "random_id" "id" {
  byte_length = 4
  prefix      = "${var.database_name_prefix}-"
}

data "google_compute_network" "default-network" {
  provider = "google-beta"
  name     = "default"
}

resource "google_compute_global_address" "private_ip_address" {
  provider      = "google-beta"
  name          = "${random_id.id.hex}-private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = "${data.google_compute_network.default-network.self_link}"
}

resource "null_resource" "vpc-to-services-peering" {
  provisioner "local-exec" {
    command = <<EOF
    gcloud beta services vpc-peerings update \
    --service servicenetworking.googleapis.com \
    --ranges=${google_compute_global_address.private_ip_address.id} \
    --network=default  \
    --project=${var.project_id} \
    --force
EOF
  }

  depends_on = ["google_compute_global_address.private_ip_address"]
}

resource "google_service_networking_connection" "private_vpc_connection" {
  depends_on              = ["null_resource.vpc-to-services-peering"]
  provider                = "google-beta"
  network                 = "${data.google_compute_network.default-network.self_link}"
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = ["${google_compute_global_address.private_ip_address.id}"]
}

resource "google_sql_database_instance" "master" {
  provider         = "google-beta"
  name             = "${random_id.id.hex}"
  region           = "${var.region}"
  database_version = "${var.database_version}"

  depends_on = [
    "google_service_networking_connection.private_vpc_connection",
  ]

  settings {
    availability_type = "${var.availability_type}"
    tier              = "${var.sql_instance_size}"
    disk_type         = "${var.sql_disk_type}"
    disk_size         = "${var.sql_disk_size}"
    disk_autoresize   = true

    ip_configuration {
      require_ssl     = "${var.sql_require_ssl}"
      ipv4_enabled    = true
      private_network = "${data.google_compute_network.default-network.self_link}"
    }

    location_preference {
      zone = "${var.region}-${var.sql_master_zone}"
    }

    backup_configuration {
      enabled    = true
      start_time = "00:00"
    }
  }
}

resource "google_sql_database" "initdatabase" {
  name     = "${google_sql_database_instance.master.name}"
  instance = "${google_sql_database_instance.master.name}"
}

resource "google_sql_user" "user" {
  depends_on = [
    "google_sql_database_instance.master",
  ]

  instance = "${google_sql_database_instance.master.name}"
  name     = "${var.sql_user}"
  password = "${var.sql_pass}"
}
