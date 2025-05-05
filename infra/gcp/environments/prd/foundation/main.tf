# These modules contain resources that can remain deployed at a low cost
module "foundation" {
  source      = "../../../modules/foundation"
  project_id  = var.project_id
  region      = var.region
  environment = var.environment
}

module "security" {
  source      = "../../../modules/security"
  project_id  = var.project_id
  environment = var.environment
}

module "storage" {
  source      = "../../../modules/storage"
  project_id  = var.project_id
  region      = var.region
  environment = var.environment
}
