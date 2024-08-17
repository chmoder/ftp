# namespcae for cert manager
resource "kubernetes_namespace_v1" "cert_manager_namespace" {
  metadata {
    name = "cert-manager"
  }

  depends_on = [google_container_node_pool.primary_nodes]
}

# cert-manager dns01 challenge api key secret
resource "kubernetes_secret_v1" "cloudflare_api_token" {
  metadata {
    name      = "cloudflare-token"
    namespace = "cert-manager"
  }

  data = {
    api_key = var.cloudflare_api_key
  }

  depends_on = [kubernetes_namespace_v1.cert_manager_namespace]
}

# you may need to edit this for your particular needs http01 / dns01 / ...
module "cert_manager" {
  source = "terraform-iaac/cert-manager/kubernetes"

  cluster_issuer_email                   = var.cluster_issuer_email
  cluster_issuer_private_key_secret_name = var.cluster_issuer_private_key_secret_name
  namespace_name                         = "cert-manager"
  create_namespace                       = "false"

  solvers = [
    {
      dns01 = {
        cloudflare = {
          email = var.cloudflare_email
          apiKeySecretRef = {
            name = "cloudflare-token"
            key  = "api_key"
          }
        },
      },
      selector = {
        dnsZones = [
          var.ingress_hosts.ftp_svc.domain
        ]
      }
    },
    {
      http01 = {
        ingress = {
          class = "nginx"
        }
      }
    }
  ]

  certificates = {
    "${var.ingress_hosts.ftp_svc.domain}" = {
      dns_names = [var.ingress_hosts.ftp_svc.domain]
    }
  }

  depends_on = [google_container_node_pool.primary_nodes, kubernetes_secret_v1.cloudflare_api_token]
}
