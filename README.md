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

### TODO

- Test on a new GCP project
- Automatic dns record (set A record to new static IP)
- Variables for Cluster and Node Pool configurations machine type, HPA, etc.
- Add monitoring (new relic)
- CloudSQL (Postgres, MySQL)
- Caching (Redis, MemoryStore)
- ...

### Notes

- You have to update your `ingress_hosts` A records in order to get traffic to your site. And to generate the SSL certificate.
- You may need to modify the `certmanager` module to support your particular certificate needs. Current implementation uses [dns01 challenge solver with cloudflare](https://cert-manager.io/docs/configuration/acme/dns01/cloudflare/).

### Usage

- Create GCP project
- Create terraform admin service account
- Download SA credentials JSON
- Set variables (`terraform.tfvars` for example)
- `terraform init`
- `terraform apply`

### Variables

```SHELL
project_id                             = "project-id"
project_region                         = "us-central1"
credentials_file_path                  = "/path/to/sa/creds.json"
sa_email                               = "terraform-admin@project-id.iam.gserviceaccount.com"
cluster_issuer_private_key_secret_name = "cert-manager-private-key"
ingress_hosts = {
  ftp_svc = "some-svc.example.com"
}
cluster_issuer_email = "your.email@gmail.com"
cloudflare_email     = "your.email@gmail.com"
name_prefix_kebab    = "some-svc"
cloudflare_api_key   = "XXX"
```
