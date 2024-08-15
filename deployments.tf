# hello world deployment
resource "kubernetes_deployment_v1" "example" {
  metadata {
    name = "${var.name_prefix_kebab}-deployment"
  }

  spec {
    selector {
      match_labels = {
        app = "${var.name_prefix_kebab}-deployment"
      }
    }

    template {
      metadata {
        labels = {
          app = "${var.name_prefix_kebab}-deployment"
        }
      }

      spec {
        container {
          image = "us-docker.pkg.dev/google-samples/containers/gke/hello-app:2.0"
          name  = "${var.name_prefix_kebab}-container"

          port {
            container_port = 8080
            name           = "${var.name_prefix_kebab}-port"
          }

          liveness_probe {
            http_get {
              path = "/"
              port = "${var.name_prefix_kebab}-port"
            }

            initial_delay_seconds = 3
            period_seconds        = 3
          }
        }
      }
    }
  }

  timeouts {
    create = "3m"
    update = "3m"
  }

  depends_on = [google_container_node_pool.primary_nodes]
}


# Service - NodePort to pod
resource "kubernetes_service_v1" "example" {
  metadata {
    name = "${var.name_prefix_kebab}-loadbalancer"
  }

  spec {
    selector = {
      app = kubernetes_deployment_v1.example.spec[0].selector[0].match_labels.app
    }

    # load_balancer_ip = google_compute_address.ftp_svc.address

    port {
      port        = 8443
      target_port = kubernetes_deployment_v1.example.spec[0].template[0].spec[0].container[0].port[0].name
      protocol    = "TCP"
    }

    type = "NodePort"
  }

  timeouts {
    create = "3m"
  }

  depends_on = [google_compute_global_address.ingress, module.cert_manager]
}

# GCE ingress with SSL
# Configure your routes here
resource "kubernetes_ingress_v1" "example" {
  wait_for_load_balancer = true
  metadata {
    name = "${var.name_prefix_kebab}-ingress"


    annotations = {
      "kubernetes.io/ingress.class"                 = "gce"
      "kubernetes.io/ingress.global-static-ip-name" = google_compute_global_address.ingress.name
      "cert-manager.io/cluster-issuer"              = module.cert_manager.cluster_issuer_name
      "networking.gke.io/v1beta1.FrontendConfig"    = kubectl_manifest.app_frontend_config.name
    }
  }

  spec {
    ingress_class_name = "gce"
    tls {
      # hosts       = [var.ingress_hosts.ftp_svc]
      hosts       = values(var.ingress_hosts)
      secret_name = var.cluster_issuer_private_key_secret_name
    }

    default_backend {
      service {
        name = kubernetes_service_v1.example.metadata.0.name
        port {
          number = kubernetes_service_v1.example.spec[0].port[0].port
        }
      }

    }

    rule {
      host = var.ingress_hosts.ftp_svc
      http {
        path {
          path = "/*"
          backend {
            service {
              name = kubernetes_service_v1.example.metadata.0.name
              port {
                number = kubernetes_service_v1.example.spec[0].port[0].port
              }
            }
          }
        }
      }
    }
  }

  depends_on = [kubernetes_service_v1.example, module.cert_manager]

  timeouts {
    create = "2m"
  }
}

# namespcae for cert manager
resource "kubernetes_namespace_v1" "cert_manager_namespace" {
  metadata {
    name = "cert-manager"
  }

  depends_on = [google_container_node_pool.primary_nodes]
}

# cert-manager dns01 secret
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

# cert manager module
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
          var.ingress_hosts.ftp_svc
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
    #  "${replace(var.ingress_hosts.ftp_svc, ".", "_")}" = {
    "${var.ingress_hosts.ftp_svc}" = {
      dns_names = [var.ingress_hosts.ftp_svc]
    }
  }

  depends_on = [google_container_node_pool.primary_nodes, kubernetes_secret_v1.cloudflare_api_token]
}
