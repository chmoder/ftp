variable "name_prefix_kebab" {
  type        = string
  description = "resource name prefix hyphenated"
}

variable "cloudflare_api_key" {
  type        = string
  description = "cloudflare api key for dns01 validation"
}