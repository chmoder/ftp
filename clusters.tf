# Cluster
resource "google_container_cluster" "primary" {
  name           = "${var.name_prefix_kebab}-gke-cluster"
  location       = var.project_region
  node_locations = ["${var.project_region}-f"]

  network = google_compute_network.example.id


  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection      = false

  depends_on = [google_project_iam_binding.cluster_admin]
}

# Node Pool
resource "google_container_node_pool" "primary_nodes" {
  name           = "${var.name_prefix_kebab}-node-pool"
  location       = google_container_cluster.primary.location
  cluster        = google_container_cluster.primary.name
  node_count     = 2
  node_locations = ["${var.project_region}-f"]

  node_config {
    spot         = true
    machine_type = "e2-standard-2"

    tags = [var.firewall_allow_http, var.firewall_allow_https]

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = var.sa_email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  lifecycle {
    ignore_changes = [node_config]
  }

  depends_on = [google_project_iam_binding.cluster_admin]
}
