module "alb" {

  source = "./modules/alb"

  project_name = var.project_name

  vpc_id = module.networking.vpc_id

  public_subnet_1_id = module.networking.public_subnet_1_id

  public_subnet_2_id = module.networking.public_subnet_2_id

  alb_security_group_id = module.security.alb_security_group_id


}