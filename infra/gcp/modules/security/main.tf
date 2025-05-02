// The security modules contains resources to handle auth and secrets.
// This includes IAM roles and policies and secret management.

# Service account for GKE
resource "google_service_account" "gke_service_account" {
  account_id   = "${var.environment}-gke-sa"
  display_name = "GKE service account for ${var.environment}"
  description  = "Service account for GKE in ${var.environment}"
}

# IAM binding for GKE service account
resource "google_project_iam_member" "gke_sa_roles" {
  for_each = toset([
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/storage.objectViewer",
    "roles/artifactregistry.reader"
  ])

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.gke_service_account.email}"
}

# Service account for ML workloads
resource "google_service_account" "ml_service_account" {
  account_id   = "${var.environment}-ml-sa"
  display_name = "ML workload service account for ${var.environment}"
  description  = "Service account for ML workloads in ${var.environment}"
}

# IAM binding for ML service account
resource "google_project_iam_member" "ml_sa_roles" {
  for_each = toset([
    "roles/storage.objectAdmin",     # For accessing ML datasets and model storage
    "roles/artifactregistry.writer", # For pushing/pulling container images
    "roles/logging.logWriter",       # For writing logs
    "roles/monitoring.metricWriter"  # For writing metrics
  ])

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.ml_service_account.email}"
}

# Secret for ML API keys or credentials
resource "google_secret_manager_secret" "ml_api_key" {
  secret_id = "${var.environment}-ml-api-key"
  replication {
    auto {}
  }

}

# Initial version of secret (empty - will be filled manually)
resource "google_secret_manager_secret_version" "ml_api_key_version" {
  secret      = google_secret_manager_secret.ml_api_key.id
  secret_data = "changeme"
}

# Grant access to the ML service account to access the secret
resource "google_secret_manager_secret_iam_member" "ml_sa_secret_access" {
  secret_id = google_secret_manager_secret.ml_api_key.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.ml_service_account.email}"
}
