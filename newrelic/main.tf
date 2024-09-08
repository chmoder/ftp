terraform {
  required_providers {
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

data "graphql_query" "account_id_query" {
  query_variables = {}
  query           = <<EOF
    query {
      actor {
        account(id: ${var.nr_account_id}) {
          cloud {
            linkedAccounts {
              id
              name
              nrAccountId
            }
          }
        }
      }
    }
    EOF
}

locals {
  response        = jsondecode(data.graphql_query.account_id_query.query_response)
  linked_accounts = local.response["data"]["actor"]["account"]["cloud"]["linkedAccounts"]

  linked_account_ids = flatten([
    for linked_account in local.linked_accounts :
    linked_account.id if linked_account.name == var.project_id && linked_account.nrAccountId == var.nr_account_id
  ])

  linked_account_id = length(local.linked_account_ids) > 0 ? local.linked_account_ids[0] : null
}

resource "google_project_iam_member" "example" {
  project = var.project_id
  role    = "roles/viewer"
  member  = "serviceAccount:${var.nr_sa}"
}

resource "google_project_iam_binding" "example" {
  project = var.project_id
  role    = "roles/serviceusage.serviceUsageConsumer"

  members = [
    "serviceAccount:${var.nr_sa}",
  ]
}

# # TODO: this errors if NR already has a linked account.  bug?
# resource "newrelic_cloud_gcp_link_account" "example" {
#   account_id = var.nr_account_id
#   project_id = var.project_id
#   name       = "${var.name_prefix_kebab}-nr-gcp-link"
# }

resource "newrelic_cloud_gcp_integrations" "example" {
  account_id        = var.nr_account_id
  linked_account_id = local.linked_account_id
  app_engine {}
  big_query {}
  big_table {}
  composer {}
  data_flow {}
  data_proc {}
  data_store {}
  fire_base_database {}
  fire_base_hosting {}
  fire_base_storage {}
  fire_store {}
  functions {}
  interconnect {}
  kubernetes {}
  load_balancing {}
  mem_cache {}
  pub_sub {}
  redis {}
  router {}
  run {}
  spanner {}
  sql {}
  storage {}
  virtual_machines {}
  vpc_access {}

  # lifecycle {
  #   ignore_changes = [kubernetes[0].metrics_polling_interval, vpc_access[0].metrics_polling_interval]
  # }
}


# TODO: https://developer.hashicorp.com/terraform/language/modules/develop/composition#module-composition
resource "helm_release" "newrelic_bundle" {
  name = "${var.name_prefix_kebab}-newrelic-bundle"

  repository = "https://helm-charts.newrelic.com"
  chart      = "nri-bundle"
  version    = "5.0.91"

  namespace        = "newrelic"
  create_namespace = true

  dependency_update = true
  upgrade_install   = true

  atomic = true
  lint   = true

  set_sensitive {
    name  = "global.licenseKey"
    value = var.nr_global_license_key
  }

  set {
    name  = "global.cluster"
    value = var.google_container_cluster_primary_name
  }

  set {
    name  = "newrelic-infrastructure.privileged"
    value = true
  }

  set {
    name  = "global.lowDataMode"
    value = true
  }

  set {
    name  = "kube-state-metrics.image.tag"
    value = "v2.10.0"
  }

  set {
    name  = "kube-state-metrics.enabled"
    value = true
  }

  set {
    name  = "kubeEvents.enabled"
    value = true
  }

  set {
    name  = "newrelic-prometheus-agent.enabled"
    value = true
  }

  set {
    name  = "newrelic-prometheus-agent.lowDataMode"
    value = true
  }

  set {
    name  = "newrelic-prometheus-agent.config.kubernetes.integrations_filter.enabled"
    value = false
  }

  set {
    name  = "newrelic-pixie.enabled"
    value = true
  }

  set_sensitive {
    name  = "newrelic-pixie.apiKey"
    value = var.nr_newrelic_pixie_api_key
  }

  set {
    name  = "pixie-chart.enabled"
    value = true
  }

  set_sensitive {
    name  = "pixie-chart.deployKey"
    value = var.nr_pixie_chart_deploy_key
  }

  set {
    name  = "pixie-chart.clusterName"
    value = var.google_container_cluster_primary_name
  }
}