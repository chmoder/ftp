resource "google_project_service" "serviceusage_api" {
  project = var.project_id
  service = "serviceusage.googleapis.com"

  disable_on_destroy = false
}

resource "google_project_service" "certificatemanager" {
  project = var.project_id
  service = "certificatemanager.googleapis.com"

  disable_on_destroy = false

  depends_on = [
    google_project_service.serviceusage_api
  ]
}

resource "google_project_service" "servicenetworking_api" {
  project = var.project_id
  service = "servicenetworking.googleapis.com"

  disable_on_destroy = false

  depends_on = [
    google_project_service.serviceusage_api
  ]
}