output "container_repo_url" {
  description = "The URL of the Artifact Registry repository"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.ml_container_repo.repository_id}"
}

output "ml_data_bucket" {
  description = "The name of the ML data bucket"
  value       = google_storage_bucket.ml_data_bucket.name
}

output "ml_models_bucket" {
  description = "The name of the ML models bucket"
  value       = google_storage_bucket.ml_models_bucket.name
}
