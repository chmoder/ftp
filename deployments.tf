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
