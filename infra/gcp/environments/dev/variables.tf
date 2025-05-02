variable "region" {
  type        = string
  description = "The region to deploy to"
}

variable "project_id" {
  type        = string
  description = "The GCP project ID"
  default     = "us-central1"
}
