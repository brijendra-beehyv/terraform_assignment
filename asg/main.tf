provider "aws" {
  region = "ap-south-1"
}

variable "launch_template_id" {
  type = string
}

variable "tg_arn" {
  type = string
}

resource "aws_autoscaling_group" "asg" {
  desired_capacity   = 0
  max_size           = 3
  min_size           = 0
  target_group_arns = [ var.tg_arn ]

  launch_template {
    id      = var.launch_template_id
    version = "$Latest"
  }
}

resource "aws_autoscaling_policy" "scale_up" {
  name                   = "my-a-policy"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
}
