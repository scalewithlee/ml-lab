output "network_id" {
  description = "The ID of the VPC network"
  value       = module.foundation.network_id
}

output "subnet_id" {
  description = "The ID of the GKE subnet"
  value       = module.foundation.subnet_id
}

output "gke_service_account_email" {
  description = "The email address of the GKE service account"
  value       = module.security.gke_service_account_email
}
