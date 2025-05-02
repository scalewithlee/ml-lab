# ML Infrastructure Module

This module provisions the core infrastructure for running machine learning workloads on GCP, including:

- GKE cluster with private nodes and custom node pools
- Artifact Registry for container images
- Cloud Storage buckets for datasets and models with versioning

## Usage

```hcl
module "ml_infra" {
  source = "../modules/ml-infra"

  project_id  = "your-gcp-project-id"
  region      = "us-central1"
  environment = "dev"

  network_id = module.foundation.network_id
  subnet_id  = module.foundation.subnet_id

  gke_service_account_email = module.security.gke_service_account_email

  node_count        = 2
  node_machine_type = "e2-standard-4"
  node_disk_size_gb = 100
  node_zones        = ["us-central1-a", "us-central1-b"]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| project_id | The GCP project ID | string | n/a | yes |
| region | The GCP region for resources | string | n/a | yes |
| environment | Environment name (dev, staging, prod) | string | n/a | yes |
| network_id | The ID of the VPC network | string | n/a | yes |
| subnet_id | The ID of the subnet for the GKE cluster | string | n/a | yes |
| gke_service_account_email | The email of the GKE service account | string | n/a | yes |
| master_ipv4_cidr_block | The CIDR block for the GKE master | string | "172.16.0.0/28" | no |
| master_authorized_networks | List of CIDR blocks that can access the Kubernetes master | list(object) | All networks (0.0.0.0/0) | no |
| node_count | Number of nodes in the GKE node pool | number | 3 | no |
| node_machine_type | Machine type for GKE nodes | string | "e2-standard-4" | no |
| node_disk_size_gb | Disk size for GKE nodes in GB | number | 100 | no |
| node_zones | Zones for GKE node locations | list(string) | [] | no |
| kms_key_id | The ID of the KMS key to use for encryption | string | null | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_name | The name of the GKE cluster |
| cluster_endpoint | The IP address of the GKE cluster |
| container_repo_url | The URL of the Artifact Registry repository |
| ml_data_bucket | The name of the ML data bucket |
| ml_models_bucket | The name of the ML models bucket |

## Architecture Design

This module implements a private GKE cluster with the following features:

- **Regional Deployment**: For high availability across multiple zones
- **Private Nodes**: Nodes have no public IP addresses for enhanced security
- **Public Control Plane**: The Kubernetes API server is publicly accessible (but can be restricted)
- **Workload Identity**: For secure authentication between GKE and GCP services
- **SSD Storage**: Fast local storage for ML workloads
- **Data Versioning**: Versioned storage buckets for datasets and models

## Best Practices

- Scale node count based on workload requirements
- Consider using preemptible instances for cost savings on non-critical workloads
- Implement proper logging and monitoring for cluster and workloads
- Use node affinity and taints to separate different types of ML workloads
- Regularly back up critical datasets and models
