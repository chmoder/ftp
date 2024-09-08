output "google_container_cluster_primary_name" {
    value = google_container_cluster.primary.name
}

output "k8_provider_config" {
    value = local.k8_provider_config
}