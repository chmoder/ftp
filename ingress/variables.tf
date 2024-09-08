variable "name_prefix_kebab" {
  type        = string
  description = "resource name prefix hyphenated"
}

variable "cluster_issuer_private_key_secret_name" {
  type        = string
  description = "eventual location of cert-manager tls key and cert"
}

variable "google_compute_global_address_ingress_name" {
    type = string
    description = "ingress name"
}

variable "kubernetes_deployment_v1_example_spec" {
  type = list
}

variable "kubernetes_service_v1_example" {
 type = any
}

variable "cert_manager_cluster_issuer_name" {
  type = string
}

variable "ingress_hosts" {
  type        = map(map(string))
  description = "hostnames (domains) that will be used in certs and/or routing"
}