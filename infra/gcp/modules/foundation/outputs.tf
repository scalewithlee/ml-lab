output "network_id" {
  description = "The ID of the VPC network"
  value       = google_compute_network.ml_network.id
}

output "network_name" {
  description = "The name of the VPC network"
  value       = google_compute_network.ml_network.name
}

output "subnet_id" {
  description = "The ID of the GKE subnet"
  value       = google_compute_subnetwork.gke_subnet.id
}

output "subnet_name" {
  description = "The name of the GKE subnet"
  value       = google_compute_subnetwork.gke_subnet.name
}
