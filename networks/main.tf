terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.39.0"
    }
  }
}

# resource "google_compute_address" "ingress" {
#   name         = "${var.name_prefix_kebab}-regional-ip-address"
#   address_type = "EXTERNAL"
# }

resource "google_compute_global_address" "ingress" {
  name         = "${var.name_prefix_kebab}-ip-address"
  address_type = "EXTERNAL"
}

resource "google_compute_network" "example" {
  name                    = "${var.name_prefix_kebab}-network"
  routing_mode            = "GLOBAL"
  auto_create_subnetworks = true
}

# private ip address block for things infrastructure on this network
# resource "google_compute_global_address" "private_ip_block" {
#   name          = "private-ip-block"
#   purpose       = "VPC_PEERING"
#   address_type  = "INTERNAL"
#   ip_version    = "IPV4"
#   prefix_length = 24
#   network       = google_compute_network.ftp_svc.self_link
# }

# this enables connections to cloudSQL instances
# resource "google_service_networking_connection" "private_vpc_connection" {
#   network                 = google_compute_network.ftp_svc.self_link
#   service                 = "servicenetworking.googleapis.com"
#   reserved_peering_ranges = [google_compute_global_address.private_ip_block.name]

#   depends_on = [
#     google_project_service.servicenetworking_api
#   ]
# }

resource "google_compute_firewall" "allow_ssh" {
  name      = "allow-ssh"
  network   = google_compute_network.example.name
  direction = "INGRESS"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_tags = [var.firewall_allow_ssh]
  target_tags = [var.firewall_allow_ssh]
}

resource "google_compute_firewall" "allow_http" {
  name      = "allow-http"
  network   = google_compute_network.example.name
  direction = "INGRESS"
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_tags = [var.firewall_allow_http]
  target_tags = [var.firewall_allow_http]
}

resource "google_compute_firewall" "allow_https" {
  name      = "allow-https"
  network   = google_compute_network.example.name
  direction = "INGRESS"
  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_tags = [var.firewall_allow_https]
  target_tags = [var.firewall_allow_https]
}

resource "cloudflare_record" "example" {
  zone_id         = var.ingress_hosts.ftp_svc.zone_id
  name            = var.ingress_hosts.ftp_svc.domain
  content         = google_compute_global_address.ingress.address
  type            = "A"
  ttl             = 60
  allow_overwrite = true
}