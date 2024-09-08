variable "cloudflare_api_key" {
  type        = string
  description = "cloudflare api key for dns01 validation"
}

variable "cluster_issuer_email" {
  type        = string
  description = "email address for cert-manager"
}

variable "cluster_issuer_private_key_secret_name" {
  type        = string
  description = "eventual location of cert-manager tls key and cert"
}

variable "cloudflare_email" {
  type        = string
  description = "email address for cert-manager"
}

variable "ingress_hosts" {
  type        = map(map(string))
  description = "hostnames (domains) that will be used in certs and/or routing"
}