# add roles to the terraform admin service account
resource "google_project_iam_binding" "cluster_admin" {
  project = var.project_id
  role    = "roles/container.clusterAdmin"

  members = [
    "serviceAccount:terraform-admin@chmoder.iam.gserviceaccount.com",
  ]
}

resource "google_project_iam_binding" "container-admin" {
  project = var.project_id
  role    = "roles/container.admin"

  members = [
    "serviceAccount:terraform-admin@chmoder.iam.gserviceaccount.com",
  ]
}

# could also use k8 RBAC
resource "google_project_iam_binding" "sa" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"

  members = [
    "serviceAccount:terraform-admin@chmoder.iam.gserviceaccount.com",
  ]
}