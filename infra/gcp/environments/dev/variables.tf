variable "region" {
  type        = string
  description = "The region to deploy to"
  default     = "us-central1"
}

variable "project_id" {
  type        = string
  description = "The GCP project ID"
}
