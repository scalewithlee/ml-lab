output "cluster_name" {
  description = "The name of the GKE cluster"
  value       = google_container_cluster.ml_cluster.name
}

output "cluster_endpoint" {
  description = "The IP address of the GKE cluster"
  value       = google_container_cluster.ml_cluster.endpoint
}

