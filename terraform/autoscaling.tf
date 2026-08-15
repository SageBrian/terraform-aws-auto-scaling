module "autoscaling" {

  source = "./modules/autoscaling"

  project_name = var.project_name

  launch_template_id = module.launch_template.launch_template_id

  launch_template_version = module.launch_template.launch_template_latest_version

  target_group_arn = module.alb.target_group_arn

  public_subnet_1_id = module.networking.public_subnet_1_id

  public_subnet_2_id = module.networking.public_subnet_2_id

  min_size         = var.min_size
  desired_capacity = var.desired_capacity
  max_size         = var.max_size

  scale_out_cpu = var.scale_out_cpu
  scale_in_cpu  = var.scale_in_cpu
}