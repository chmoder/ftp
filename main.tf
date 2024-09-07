module "providers" {
  source = "./providers"
  sa_credentials_file_path = var.sa_credentials_file_path
  project_id = var.project_id
  project_region = var.project_region
  cloudflare_email = var.cloudflare_email
  cloudflare_api_key = var.cloudflare_api_key
  nr_account_id = var.nr_account_id
  nr_api_key = var.nr_api_key
}

module "apis" {
  source = "./apis"

  project_id = var.project_id

  depends_on = [module.providers]
}

module "iam" {
  source = "./iam"

  project_id = var.project_id
  depends_on = [module.apis]
}

module "networks" {
  source = "./networks"

  name_prefix_kebab    = var.name_prefix_kebab
  firewall_allow_ssh   = var.firewall_allow_ssh
  firewall_allow_http  = var.firewall_allow_http
  firewall_allow_https = var.firewall_allow_https

  depends_on = [module.iam]
}

module "clusters" {
  source = "./clusters"

  name_prefix_kebab                          = var.name_prefix_kebab
  firewall_allow_http                        = var.firewall_allow_http
  firewall_allow_https                       = var.firewall_allow_https
  project_region                             = var.project_region
  example_network_id                         = module.networks.outputs.example_network_id
  google_compute_global_address_ingress_name = module.networks.outputs.google_compute_global_address_ingress_name

  depends_on = [module.networks]
}

module "deployments" {
  source = "./deployments"

  name_prefix_kebab  = var.name_prefix_kebab
  cloudflare_api_key = var.cloudflare_api_key

  depends_on = [module.clusters]
}

module "certmanager_a" {
  source = "./certmanager"

  ingress_hosts                          = var.ingress_hosts
  cloudflare_api_key                     = var.cloudflare_api_key
  cluster_issuer_email                   = var.cluster_issuer_email
  cloudflare_email                       = var.cloudflare_email
  cluster_issuer_private_key_secret_name = module.clusters.outputs.cluster_issuer_private_key_secret_name
  depends_on                             = [module.deployments]
}

module "services" {
  source = "./services"

  name_prefix_kebab                     = var.name_prefix_kebab
  kubernetes_deployment_v1_example_spec = module.deployments.outputs.kubernetes_deployment_v1_example_spec

  depends_on = [module.deployments, module.certmanager_a]
}

module "ingress" {
  source = "./ingress"

  name_prefix_kebab                          = var.name_prefix_kebab
  google_compute_global_address_ingress_name = module.clusters.outputs.google_compute_global_address_ingress_name
  kubernetes_deployment_v1_example_spec      = module.deployments.outputs.kubernetes_deployment_v1_example_spec
  cluster_issuer_private_key_secret_name     = module.clusters.outputs.cluster_issuer_private_key_secret_name

  depends_on = [module.services, module.deployments]
}

module "newrelic" {
  source = "./newrelic"

  project_id                            = var.project_id
  name_prefix_kebab                     = var.name_prefix_kebab
  nr_global_license_key                 = var.nr_global_license_key
  nr_account_id                         = var.nr_account_id
  nr_newrelic_pixie_api_key             = var.nr_newrelic_pixie_api_key
  nr_sa                                 = var.nr_sa
  nr_pixie_chart_deploy_key             = var.nr_pixie_chart_deploy_key
  google_container_cluster_primary_name = module.clusters.outputs.google_container_cluster_primary_name

  depends_on = [module.deployments]
}

