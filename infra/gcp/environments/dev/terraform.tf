terraform {
  required_version = ">= 1.0.0"

  backend "gcs" {
    # This will be filled in with `terraform init -backend-config="bucket=your-bucket"
    # The bucket must already exist before terraform init
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}
