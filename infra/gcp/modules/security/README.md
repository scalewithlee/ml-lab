# Security Module

This module provides security controls for ML infrastructure on GCP, including:

- Service Accounts with least-privilege permissions
- Secret management for API keys and credentials
- IAM role bindings with proper access controls

## Usage

```hcl
module "security" {
  source = "../modules/security"

  project_id  = "your-gcp-project-id"
  environment = "dev"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| project_id | The GCP project ID | string | n/a | yes |
| environment | Environment name (dev, staging, prod) | string | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| gke_service_account_email | The email of the GKE service account |
| ml_service_account_email | The email of the ML service account |
| ml_api_key_secret_id | The ID of the ML API key secret |

## Security Features

- **Least Privilege Access**: Service accounts are configured with minimal permissions needed to operate
- **Secret Management**: Uses Google Secret Manager for secure credential storage
- **Identity Separation**: Different service accounts for GKE infrastructure and ML workloads

## Best Practices

- Never store actual secret values in Terraform code
- Regularly rotate service account keys
- Review IAM permissions periodically to ensure they remain appropriate
- Consider implementing VPC Service Controls for enhanced security in production environments
