provider "aws" {
  region = "ap-south-1"
}

variable "launch_template_id" {
  type = string
}

variable "tg_arn" {
  type = string
}

variable "lb_id" {
  type = string
}

resource "aws_autoscaling_group" "asg" {
  desired_capacity  = 1
  max_size          = 3
  min_size          = 0

  launch_template {
    id      = var.launch_template_id
    version = "$Latest"
  }
}

resource "aws_autoscaling_attachment" "a-asg-lb-attachment" {
  autoscaling_group_name = aws_autoscaling_group.asg.name
  lb_target_group_arn = var.tg_arn
}
