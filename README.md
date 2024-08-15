# Kubernetes Bootstrap

### Features

- Dynamic name for the product
- Dynamic domain names for ingress and certificates
- Automatic SSL Cert generation
- NodePort LoadBalancer service for deployments
- GCE Ingress tls setup
- Frontend LB HTTP -> HTTPS redirect

### TODO

- Automatic dns record (set A record to new static IP)

### Notes

- You have to update your `ingress_hosts` A records in order to get traffic to your site. And to generate the SSL certificate.

### Usage

- set variables (`terraform.tfvars` for example)
- terraform init
- terraform apply

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
