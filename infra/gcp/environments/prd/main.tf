module "foundational" {
  source      = "../../modules/foundational"
  project_id  = var.project_id
  region      = var.region
  environment = "prd"
}

module "security" {
  source      = "../../modules/security"
  project_id  = var.project_id
  environment = "prd"
}

module "ml_infra" {
  source      = "../../modules/ml-infra"
  project_id  = var.project_id
  region      = var.region
  environment = "prd"

  # Pass outputs from foundational module
  network_id = module.foundational.network_id
  subnet_id  = module.foundational.subnet_id

  # Pass outputs from security module
  gke_service_account_email = module.security.gke_service_account_email

  # Customize GKE cluster
  node_count        = 2
  node_machine_type = "e2-standard-4"
  node_disk_size_gb = 50
  node_zones        = ["${var.region}-a", "${var.region}-b"]
}
