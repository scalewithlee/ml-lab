variable "gcp_services" {
  type        = list(string)
  description = "GCP services that are required (to enable the APIs)"
  default = [
    "cloudresourcemanager.googleapis.com", # Might have to add this one manually
    "artifactregistry.googleapis.com",
    "container.googleapis.com",
    "iam.googleapis.com",
    "secretmanager.googleapis.com"
  ]
}

variable "project_id" {
  type        = string
  description = "The ID of the GCP project"
}

variable "region" {
  type        = string
  description = "The region to use for GCP resources"
  default     = "us-central1"
}

variable "environment" {
  type        = string
  description = "The environment to deploy to"
}

variable "gke_subnet_cidr" {
  type        = string
  description = "The CIDR block for the GKE subnet"
  default     = "10.0.0.0/20"
}

variable "gke_pod_cidr" {
  type        = string
  description = "The CIDR block for the GKE pod network"
  default     = "10.16.0.0/14"
}

variable "gke_service_cidr" {
  type        = string
  description = "The CIDR block for the GKE service network"
  default     = "10.20.0.0/20"
}
