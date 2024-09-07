output "network_example_id" {
    value = google_compute_network.example.id
    description = "The network ID for the \"example\" network"
}

output "google_compute_global_address_ingress_name" {
    value = google_compute_global_address.ingress.name
}