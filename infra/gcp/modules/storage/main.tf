# Cloud storage bucket for ML datasets
resource "google_storage_bucket" "ml_data_bucket" {
  name          = "${var.project_id}-${var.environment}-ml-data"
  location      = var.region
  force_destroy = var.environment != "prd" # Allow only force-destroy in non-prd environments

  versioning {
    enabled = true
  }

  uniform_bucket_level_access = true

  # Set appropriate lifecycle rules for different data types
  lifecycle_rule {
    condition {
      age        = 90 # 90 days
      with_state = "ARCHIVED"
    }
    action {
      type = "Delete"
    }
  }

  # Apply encryption if key is provided
  dynamic "encryption" {
    for_each = var.kms_key_id != null ? [1] : []
    content {
      default_kms_key_name = var.kms_key_id
    }
  }
}

# Cloud storage bucket for ML models
resource "google_storage_bucket" "ml_models_bucket" {
  name          = "${var.project_id}-${var.environment}-ml-models"
  location      = var.region
  force_destroy = var.environment != "prd" # Only allow force destroy in non-prd environments

  # Enable versioning for models
  versioning {
    enabled = true
  }

  # Apply uniform bucket-level access
  uniform_bucket_level_access = true

  # Apply encryption, if key is provided
  dynamic "encryption" {
    for_each = var.kms_key_id != null ? [1] : []
    content {
      default_kms_key_name = var.kms_key_id
    }
  }
}

# Artifact registry repository for container images
resource "google_artifact_registry_repository" "ml_container_repo" {
  location      = var.region
  repository_id = "${var.environment}-ml-containers"
  description   = "Docker repository for ML containers in ${var.environment}"
  format        = "DOCKER"
}
