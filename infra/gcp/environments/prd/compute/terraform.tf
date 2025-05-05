# environments/dev/foundation/terraform.tf
terraform {
  required_version = ">= 1.0.0"

  backend "gcs" {
    # Configuration will come from backend.conf
    # through terraform init -backend-config
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}
