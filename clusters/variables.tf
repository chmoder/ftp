variable "name_prefix_kebab" {
  type        = string
  description = "resource name prefix hyphenated"
}

variable "project_region" {
  type        = string
  description = "GCP Project Region"
}

variable "firewall_allow_http" {
  type    = string
  default = "http-enabled"
}

variable "firewall_allow_https" {
  type    = string
  default = "https-enabled"
}

variable "example_network_id" {
  type    = string
}

variable "google_compute_global_address_ingress_name" {
  type=string
}