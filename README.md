# Kubernetes Bootstrap

Deploy a platform on Google Cloud by setting up basic infrastructure using variables.

### Features

- IAM
- Separate Network
- Kubernetes Cluster
- Cert Manager SSL certificate generation and management
- TLS GCE Ingress
- HTTP -> HTTPS redirect
- Variable defined name for the infrastructure components
- Variable defined domain names for ingress and certificates
- New Relic and pixie integration
- Cloudflare DNS A record create and update for static ingress IP

### TODO

- ~~Refactor using module composition and Dependency Inversion~~
- Test on a new GCP project
- ~~Automatic dns record (set A record to new static IP)~~
- Variables for Cluster and Node Pool configurations machine type, HPA, etc.
- ~~Add monitoring (new relic)~~
- CloudSQL (Postgres, MySQL)
- Caching (Redis, MemoryStore)
- Use gitops instead of helm charts - maybe for new relic
- ...

### Notes

- ~~You have to update your `ingress_hosts` A records in order to get traffic to your site. And to generate the SSL certificate.~~
- You may need to modify the `certmanager` module to support your particular certificate needs. Current implementation uses [dns01 challenge solver with cloudflare](https://cert-manager.io/docs/configuration/acme/dns01/cloudflare/).
- There is a bug with the `newrelic_cloud_gcp_link_account` resource https://github.com/newrelic/terraform-provider-newrelic/issues/2733

### Usage

- Create GCP project
- Create terraform admin service account
- Download SA credentials JSON
- Set variables (`terraform.tfvars` for example)
- `terraform init`
- `terraform apply`

### Variables

```SHELL
name_prefix_kebab                      = "some-svc"
project_id                             = "project-id"
project_region                         = "us-central1"
sa_credentials_file_path               = "/path/to/sa/creds.json"
sa_email                               = "terraform-admin@project-id.iam.gserviceaccount.com"

# https://github.com/cert-manager/cert-manager
cluster_issuer_private_key_secret_name = "cert-manager-private-key"
cluster_issuer_email = "your.email@gmail.com"
ingress_hosts = {
  ftp_svc = {
    "zone_id" = "XXX"
    "domain"  = "some-svc.example.com"
  }
}

cloudflare_email     = "your.email@gmail.com"
cloudflare_api_key   = "XXX"

# https://docs.newrelic.com/install/kubernetes/
nr_account_id             = 1234567
nr_api_key                = "NRAK-XXX"
nr_sa                     = "randomAccount@newrelic-gcp.iam.gserviceaccount.com"
nr_global_license_key     = "XXX"
nr_newrelic_pixie_api_key = "XXX"
nr_pixie_chart_deploy_key = "XXX"

```
