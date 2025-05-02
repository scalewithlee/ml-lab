#!/usr/bin/env bash
# This script creates the terraform state bucket on GCP, which
# will then be used to store the state of the infrastructure.
# This should be ran once, from your local machine.
set -e

# Check command line args
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: $0 <project-id> <environment>"
  echo "Example: $0 my-project dev"
  exit 1
fi

PROJECT_ID="$1"
ENVIRONMENT="$2"
REGION="us-central1"
BUCKET_NAME="${PROJECT_ID}-terraform-state"

# Check if environment directory exists
ENV_DIR="infra/gcp/environments/${ENVIRONMENT}"
if [ ! -d "$ENV_DIR" ]; then
  echo "=== Environment directory does not exist: $ENV_DIR ==="
  exit 1
fi

echo "======== Bootstrapping Terraform state for project $PROJECT_ID for $ENVIRONMENT ========"

mkdir bootstrap
cd bootstrap

# Create minimal terraform config for the state bucket
cat > main.tf <<EOF
provider "google" {
    project = "${PROJECT_ID}"
    region  = "${REGION}"
}

resource "google_storage_bucket" "terraform_state" {
    name          = "${BUCKET_NAME}"
    location      = "${REGION}"
    force_destroy = true

    versioning {
        enabled = true
    }

    uniform_bucket_level_access = true
}

output "state_bucket_name" {
    value = google_storage_bucket.terraform_state.name
}
EOF

# Initialize and apply to create the state bucket
echo "======== Creating state bucket ========="
terraform init
terraform apply

# Get bucket name from output
STATE_BUCKET=$(terraform output -raw state_bucket_name)
echo "======== State bucket created: $STATE_BUCKET ========"

cd ..
cd "${ENV_DIR}"

# Update the backend config
cat > backend.conf <<EOF
bucket = "${STATE_BUCKET}"
prefix = "terraform/state/${ENVIRONMENT}"
EOF

echo "======== Initializing ${ENVIRONMENT} environment with remote state ========"
terraform init -backend-config=backend.conf

echo "======== Bootstrap complete! ========"
echo "Your Terraform state for ${ENVIRONMENT} is now stored in GCS bucket: $STATE_BUCKET"
echo "State path: terraform/state/${ENVIRONMENT}"
