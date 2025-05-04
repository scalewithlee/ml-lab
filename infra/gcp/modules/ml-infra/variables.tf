variable "project_id" {
  type        = string
  description = "The GCP project ID"
}

variable "region" {
  type        = string
  description = "The GCP region"
}

variable "environment" {
  type        = string
  description = "The environment name"
}

variable "node_zones" {
  type        = list(string)
  description = "Availability zones for the GKE cluster nodes"
  default     = []
}

variable "network_id" {
  type        = string
  description = "The GCP network ID"
}

variable "subnet_id" {
  type        = string
  description = "The GCP subnet ID"
}

variable "master_authorized_networks" {
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  description = "List of CIDR blocks that can access the Kubernetes master through HTTPS"
  default = [{
    cidr_block   = "0.0.0.0/0"
    display_name = "All networks"
  }]
}

variable "master_ipv4_cidr_block" {
  type        = string
  description = "The CIDR block for the GKE master"
  default     = "172.16.0.0/28"
}

variable "node_count" {
  type        = number
  description = "The number of nodes in the GKE node pool"
  default     = 3
}

variable "node_machine_type" {
  type        = string
  description = "The machine type for the GKE cluster nodes"
  default     = "e2-standard-4"
}

variable "node_disk_size_gb" {
  type        = number
  description = "The disk size in GB for the GKE cluster nodes"
  default     = 100
}

variable "gke_service_account_email" {
  type        = string
  description = "The email address of the GKE service account"
}

variable "kms_key_id" {
  type        = string
  description = "The ID of the KMS key to use for storage encryption"
  default     = null
}
