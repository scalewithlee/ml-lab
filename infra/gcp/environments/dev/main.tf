module "foundational" {
  source      = "../../modules/foundational"
  project_id  = var.project_id
  region      = var.region
  environment = "dev"
}
