data "google_client_config" "example" {}

locals {
  k8_provider_config = {
    host                   = "https://${google_container_cluster.primary.endpoint}"
    token                  = data.google_client_config.example.access_token
    cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)

    ignore_annotations = [
      "^autopilot\\.gke\\.io\\/.*",
      "^cloud\\.google\\.com\\/.*"
    ]
  }
}

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
    helm = {
      source  = "hashicorp/helm"
      version = "2.15.0"
    }
    newrelic = {
      source  = "newrelic/newrelic"
      version = "3.42.1"
    }
  }
}

provider "google" {
  credentials = file(var.credentials_file_path)
  project     = var.project_id
  region      = var.project_region
}

provider "kubernetes" {
  host                   = local.k8_provider_config.host
  token                  = local.k8_provider_config.token
  cluster_ca_certificate = local.k8_provider_config.cluster_ca_certificate

  ignore_annotations = local.k8_provider_config.ignore_annotations
}

provider "kubectl" {
  host                   = local.k8_provider_config.host
  token                  = local.k8_provider_config.token
  cluster_ca_certificate = local.k8_provider_config.cluster_ca_certificate
}

provider "helm" {
  kubernetes {
    host                   = local.k8_provider_config.host
    token                  = local.k8_provider_config.token
    cluster_ca_certificate = local.k8_provider_config.cluster_ca_certificate
  }
}

# TODO: implement newrelic
# provider "newrelic" {
#   account_id = var.nr_account_id
#   api_key    = ""
#   region     = "US"
# }