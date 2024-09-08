data "google_client_config" "example" {}
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.41.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.32.0"
    }
    kubectl = {
      source  = "alekc/kubectl"
      version = "2.0.4"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.39.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.15.0"
    }
    newrelic = {
      source  = "newrelic/newrelic"
      version = "3.45.0"
    }
    graphql = {
      source  = "sullivtr/graphql"
      version = "2.5.5"
    }
  }
}

provider "google" {
  credentials = file(var.sa_credentials_file_path)
  project     = var.project_id
  region      = var.project_region
}

provider "kubernetes" {
  host                   = module.clusters.k8_provider_config.host
  token                  = data.google_client_config.example.access_token
  cluster_ca_certificate = module.clusters.k8_provider_config.cluster_ca_certificate
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "gke-gcloud-auth-plugin"
  }
}

provider "kubectl" {
  host                   = module.clusters.k8_provider_config.host
  token                  = data.google_client_config.example.access_token
  cluster_ca_certificate = module.clusters.k8_provider_config.cluster_ca_certificate
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "gke-gcloud-auth-plugin"
  }
}

provider "helm" {
  kubernetes {
    host                   = module.clusters.k8_provider_config.host
    token                  = data.google_client_config.example.access_token
    cluster_ca_certificate = module.clusters.k8_provider_config.cluster_ca_certificate
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "gke-gcloud-auth-plugin"
    }
  }
}

provider "cloudflare" {
  email   = var.cloudflare_email
  api_key = var.cloudflare_api_key
}

provider "newrelic" {
  account_id = var.nr_account_id
  api_key    = var.nr_api_key
  region     = "US"
}

provider "graphql" {
  url = "https://api.newrelic.com/graphql"
  headers = {
    "Content-Type" = "application/json"
    "API-Key"      = var.nr_api_key
  }
}

# module "providers" {
#   source                   = "./providers"
#   sa_credentials_file_path = var.sa_credentials_file_path
#   project_id               = var.project_id
#   project_region           = var.project_region
#   cloudflare_email         = var.cloudflare_email
#   cloudflare_api_key       = var.cloudflare_api_key
#   nr_account_id            = var.nr_account_id
#   nr_api_key               = var.nr_api_key
# }

module "apis" {
  source = "./apis"

  project_id = var.project_id
}

module "iam" {
  source = "./iam"

  project_id = var.project_id
  depends_on = [module.apis]
}

module "networks" {
  source = "./networks"

  ingress_hosts        = var.ingress_hosts
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
  example_network_id                         = module.networks.example_network_id
  google_compute_global_address_ingress_name = module.networks.google_compute_global_address_ingress_name

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
  cluster_issuer_private_key_secret_name = var.cluster_issuer_private_key_secret_name

  depends_on = [module.deployments]
}

module "services" {
  source = "./services"

  name_prefix_kebab                     = var.name_prefix_kebab
  kubernetes_deployment_v1_example_spec = module.deployments.kubernetes_deployment_v1_example_spec

  depends_on = [module.certmanager_a]
}

module "ingress" {
  source = "./ingress"

  name_prefix_kebab                          = var.name_prefix_kebab
  google_compute_global_address_ingress_name = module.networks.google_compute_global_address_ingress_name
  kubernetes_deployment_v1_example_spec      = module.deployments.kubernetes_deployment_v1_example_spec
  cluster_issuer_private_key_secret_name     = var.cluster_issuer_private_key_secret_name
  kubernetes_service_v1_example              = module.services.kubernetes_service_v1_example
  cert_manager_cluster_issuer_name           = module.certmanager_a.cluster_issuer_name
  ingress_hosts                              = var.ingress_hosts

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
  google_container_cluster_primary_name = module.clusters.google_container_cluster_primary_name

  depends_on = [module.ingress]
}

