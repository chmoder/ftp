# Service - NodePort to pod
resource "kubernetes_service_v1" "example" {
  metadata {
    name = "${var.name_prefix_kebab}-loadbalancer"
  }

  spec {
    selector = {
      app = var.kubernetes_deployment_v1_example_spec[0].selector[0].match_labels.app
    }

    port {
      port        = 8443
      target_port = var.kubernetes_deployment_v1_example_spec[0].template[0].spec[0].container[0].port[0].name
      protocol    = "TCP"
    }

    type = "NodePort"
  }

  timeouts {
    create = "3m"
  }

  depends_on = [google_compute_global_address.ingress, module.cert_manager]
}