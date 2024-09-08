variable "name_prefix_kebab" {
  type        = string
  description = "resource name prefix hyphenated"
}

# optional
variable "firewall_allow_ssh" {
  type    = string
  default = "ssh-enabled"
}

variable "firewall_allow_http" {
  type    = string
  default = "http-enabled"
}

variable "firewall_allow_https" {
  type    = string
  default = "https-enabled"
}

variable "ingress_hosts" {
  type        = map(map(string))
  description = "hostnames (domains) that will be used in certs and/or routing"
}