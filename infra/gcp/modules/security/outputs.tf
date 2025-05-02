output "gke_service_account_email" {
  description = "The email address of the GKE service account"
  value       = google_service_account.gke_service_account.email
}

output "ml_service_account_email" {
  description = "The email address of the ML service account"
  value       = google_service_account.ml_service_account.email
}

output "ml_api_secret_key_id" {
  description = "The ID of the ML API key secret"
  value       = google_secret_manager_secret.ml_api_key.id
}
