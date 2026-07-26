module "security" {

  source = "./modules/security"

  project_name = var.project_name

  vpc_id = module.networking.vpc_id

}