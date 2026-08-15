module "launch_template" {

  source = "./modules/launch_template"

  project_name = var.project_name

  ami_id = data.aws_ami.amazon_linux.id

  instance_type = var.instance_type

  security_group_id = module.security.ec2_security_group_id

  instance_profile_name = module.iam.instance_profile_name

}