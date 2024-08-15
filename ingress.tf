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