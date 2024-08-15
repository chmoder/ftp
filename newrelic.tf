# TODO: 
# - upgrade my google cloud account to support gcp_service_account_id
# - add new relic resources for alerts, metrics, thresholds, etc.

# resource "google_project_iam_member" "new_relic" {
#   project = var.project_id

#   for_each = toset([
#     "roles/viewer",
#     "roles/serviceusage.serviceUsageConsumer",

#   ])
#   role = each.key

#   member = "serviceAccount:gx6g4neyj6j@newrelic-gcp.iam.gserviceaccount.com"
# }

# module "newrelic-gcp-cloud-integrations" {
#   source = "github.com/newrelic/terraform-provider-newrelic//examples/modules/cloud-integrations/gcp"

#   name                   = "${var.name_prefix_kebab}"
#   newrelic_account_id    = var.nr_account_id
#   gcp_service_account_id = "gx6g4neyj6j@newrelic-gcp.iam.gserviceaccount.com"
#   gcp_project_id         = var.project_id

#   depends_on = [google_project_iam_member.new_relic]
# }