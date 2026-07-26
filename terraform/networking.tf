module "networking" {

  source = "./modules/networking"

  project_name = var.project_name

  vpc_cidr = var.vpc_cidr

  public_subnet_1_cidr = var.public_subnet_1_cidr

  public_subnet_2_cidr = var.public_subnet_2_cidr

  availability_zone_1 = data.aws_availability_zones.available.names[0]
  availability_zone_2 = data.aws_availability_zones.available.names[1]

}