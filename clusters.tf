# Cluster
resource "google_container_cluster" "primary" {
  name           = "${var.name_prefix_kebab}-gke-cluster"
  location       = var.project_region
  node_locations = ["${var.project_region}-f"]

  network = google_compute_network.example.id


  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection      = false

  maintenance_policy {
    daily_maintenance_window {
      start_time = "07:00"
    }
  }

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
    machine_type = "n2-standard-2"
    disk_size_gb = 20
    disk_type    = "pd-standard"

    tags = [var.firewall_allow_http, var.firewall_allow_https]
  }

  management {
    auto_upgrade = true
    auto_repair  = true
  }

  depends_on = [google_project_iam_binding.cluster_admin]
}
