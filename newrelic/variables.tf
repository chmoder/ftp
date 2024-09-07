variable "name_prefix_kebab" {
  type        = string
  description = "resource name prefix hyphenated"
}

variable "project_id" {
  type        = string
  description = "GCP project id"
}

variable "nr_sa" {
  type        = string
  description = "new relic service accout"
}

variable "nr_account_id" {
  type        = number
  description = "new relic account ID"
}

variable "nr_global_license_key" {
  type        = string
  description = "global.licenseKey"
}

variable "nr_newrelic_pixie_api_key" {
  type        = string
  description = "newrelic-pixie.apiKey"
}

variable "nr_pixie_chart_deploy_key" {
  type        = string
  description = "pixie-chart.deployKey"
}

variable "google_container_cluster_primary_name" {
  type        = string
}