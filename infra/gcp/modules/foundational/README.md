# Foundation module

This module provides foundational resources for ML infrastructure on GCP.

- Remote state bucket with versioning
- VPC network with private subnets
- NAT gateway for outbound traffic
- Firewall rules for secure communication

## Usage

```hcl
module "foundation" {
  source = "../modules/foundational"

  project_id  = "your-gcp-project-id"
  environment = "dev"
  region      = "us-central1"
}
```

## Inputs

Name | Description | Type | Default | Required
--- | --- | --- | --- | ---
project_id | The ID of the GCP project | string | n/a | yes
region | The GCP region for resources | string | "us-central1" | no
environment | The environment name | string | n/a | yes
gke_subnet_cidr | CIDR block for GKE subnet | string | "10.0.0.0/20" | no
gke_pod_cidr | CIDR block for GKE pod network | string | "10.16.0.0/14" | no
gke_service_cidr | CIDR block for GKE service network | string | "10.20.0.0/20" | no

## Outputs

Name | Description
--- | ---
network_id | The ID of the VPC network
network_name | The name of the VPC network
subnet_id | The ID of the GKE subnet
subnet_name | The name of the GKE subnet
terraform_state_bucket | The name of the GCS bucket for Terraform state
