# This module contains resources that can be easily taken down to save cost

data "terraform_remote_state" "foundation" {
  backend = "gcs"
  config = {
    bucket = "${var.project_id}-terraform-state"
    prefix = "terraform/state/${var.environment}/foundation"
  }
}

module "compute" {
  source      = "../../../modules/compute"
  project_id  = var.project_id
  region      = var.region
  environment = "dev"

  # Use outputs from the foundation module
  network_id                = data.terraform_remote_state.foundation.outputs.network_id
  subnet_id                 = data.terraform_remote_state.foundation.outputs.subnet_id
  gke_service_account_email = data.terraform_remote_state.foundation.outputs.gke_service_account_email

  node_count        = 1 # Will create x nodes in each availability zone
  node_machine_type = "e2-standard-4"
  node_disk_size_gb = 50
  node_zones        = ["${var.region}-a", "${var.region}-b"]
}
