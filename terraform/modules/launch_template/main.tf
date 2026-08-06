resource "aws_launch_template" "web" {

  name_prefix = "${var.project_name}-"

  image_id = var.ami_id

  instance_type = var.instance_type

  vpc_security_group_ids = [
    var.security_group_id
  ]

  user_data = base64encode(
    file("${path.root}/userdata/install.sh")
  )

  iam_instance_profile {
    name = var.instance_profile_name
  }

  update_default_version = true

  block_device_mappings {

    device_name = "/dev/xvda"

    ebs {

      volume_size = 8

      volume_type = "gp3"

      delete_on_termination = true

      encrypted = true

    }

  }

  monitoring {
    enabled = true
  }

  tag_specifications {

    resource_type = "instance"

    tags = {
      Name = "${var.project_name}-ec2"
    }

  }

}