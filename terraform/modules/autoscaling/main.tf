resource "aws_autoscaling_group" "web" {

  name = "${var.project_name}-asg"

  min_size         = var.min_size
  desired_capacity = var.desired_capacity
  max_size         = var.max_size

  vpc_zone_identifier = [
    var.public_subnet_1_id,
    var.public_subnet_2_id
  ]

  target_group_arns = [
    var.target_group_arn
  ]

  health_check_type = "ELB"

  health_check_grace_period = 300

  launch_template {

    id = var.launch_template_id

    version = var.launch_template_version

  }

  tag {

    key = "Name"

    value = "${var.project_name}-ec2"

    propagate_at_launch = true

  }

}

resource "aws_autoscaling_policy" "scale_out" {

  name = "${var.project_name}-scale-out"

  autoscaling_group_name = aws_autoscaling_group.web.name

  policy_type = "SimpleScaling"

  adjustment_type = "ChangeInCapacity"

  scaling_adjustment = 1

  cooldown = 300
}

resource "aws_autoscaling_policy" "scale_in" {

  name = "${var.project_name}-scale-in"

  autoscaling_group_name = aws_autoscaling_group.web.name

  policy_type = "SimpleScaling"

  adjustment_type = "ChangeInCapacity"

  scaling_adjustment = -1

  cooldown = 300
}

resource "aws_cloudwatch_metric_alarm" "high_cpu" {

  alarm_name = "${var.project_name}-high-cpu"

  comparison_operator = "GreaterThanThreshold"

  evaluation_periods = 2

  metric_name = "CPUUtilization"

  namespace = "AWS/EC2"

  period = 60

  statistic = "Average"

  threshold = var.scale_out_cpu

  alarm_description = "Scale out when average CPU exceeds threshold"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web.name
  }

  alarm_actions = [
    aws_autoscaling_policy.scale_out.arn
  ]

}

resource "aws_cloudwatch_metric_alarm" "low_cpu" {

  alarm_name = "${var.project_name}-low-cpu"

  comparison_operator = "LessThanThreshold"

  evaluation_periods = 2

  metric_name = "CPUUtilization"

  namespace = "AWS/EC2"

  period = 60

  statistic = "Average"

  threshold = var.scale_in_cpu

  alarm_description = "Scale in when average CPU falls below threshold"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web.name
  }

  alarm_actions = [
    aws_autoscaling_policy.scale_in.arn
  ]

}