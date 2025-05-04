// The ml-infra module contains resources that support running containerized ML workloads.
// This includes a GKE cluster, container registry, and cloud storage to store datasets and models.

# Artifact registry repository for container images
resource "google_artifact_registry_repository" "ml_container_repo" {
  location      = var.region
  repository_id = "${var.environment}-ml-containers"
  description   = "Docker repository for ML containers in ${var.environment}"
  format        = "DOCKER"
}

# GKE cluster for ML workflows
resource "google_container_cluster" "ml_cluster" {
  name     = "${var.environment}-ml-cluster"
  location = var.region

  # Use a regional cluster for high availability
  node_locations = var.node_zones

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible node pool
  # and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  # Enable workload identity for GKE.
  # This allows Kubernetes service accounts to act as user-managed Google IAM Service Accounts
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # Use VPC-native clusters with alias IPs
  networking_mode = "VPC_NATIVE"
  network         = var.network_id
  subnetwork      = var.subnet_id

  ip_allocation_policy {
    cluster_secondary_range_name  = "pod-range"
    services_secondary_range_name = "service-range"
  }

  # Configure private cluster settings
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }

  # Configure master authorized networks (allowed IPs to access the API server)
  master_authorized_networks_config {
    gcp_public_cidrs_access_enabled = true
    dynamic "cidr_blocks" {
      for_each = var.master_authorized_networks
      content {
        cidr_block   = cidr_blocks.value.cidr_block
        display_name = cidr_blocks.value.display_name
      }
    }
  }
}

# Node pool for ML workloads
resource "google_container_node_pool" "ml_nodes" {
  name       = "${var.environment}-ml-node-pool"
  version    = var.cluster_version
  cluster    = google_container_cluster.ml_cluster.id
  node_count = var.node_count

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  lifecycle {
    ignore_changes = [
      node_config[0].resource_labels["goog-gke-node-pool-provisioning-model"]
    ]
  }

  node_config {
    machine_type = var.node_machine_type

    # Specify proper disk size for ML workflows
    disk_size_gb = var.node_disk_size_gb
    disk_type    = "pd-ssd"

    # Configure service account for node pool
    service_account = var.gke_service_account_email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    # Enable workload identity
    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    # Add kubelet_config to avoid terraform apply modification errors
    kubelet_config {
      cpu_manager_policy = "static"
    }

    # Apply resource labels to nodes
    labels = {
      environment = var.environment
      role        = "ml-workload"
    }

    # Apply resource tags to nodes
    tags = ["${var.environment}-ml-nodes"]
  }
}

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
