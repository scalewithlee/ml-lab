variable "project_id" {
  type        = string
  description = "GCP project ID"
}

variable "environment" {
  type        = string
  description = "The environment to deploy to"
}

variable "region" {
  type        = string
  description = "The GCP region"
  default     = "us-central1"
}

variable "kms_key_id" {
  type        = string
  description = "The ID of the KMS key to use for storage encryption"
  default     = null
}
