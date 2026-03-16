provider "aws" {
  region = "ap-south-1"
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "ec2_instance_id" {
  type = string
}


resource "aws_security_group" "a_alb_sg" {
  name        = "web-server"
  description = "Allow incoming HTTP Connections"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_alb" "a_alb" {
  name            = "a-alb"
  internal        = false
  ip_address_type = "ipv4"
  security_groups = [aws_security_group.a_alb_sg.id]
  subnets         = var.subnet_ids
}

resource "aws_lb_target_group" "target-group" {
  health_check {
    interval            = 10
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  name        = "test-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id
}

resource "aws_lb_target_group_attachment" "ec2_attach" {
  target_group_arn = aws_lb_target_group.target-group.arn
  target_id        = var.ec2_instance_id
  port             = 80
}

resource "aws_lb_listener" "alb-listener" {
  load_balancer_arn = aws_alb.a_alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_lb_target_group.target-group.arn
    type             = "forward"
  }
}

resource "aws_lb_listener_rule" "error_rule" {
  listener_arn = aws_lb_listener.alb-listener.arn
  priority     = 100

  action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Page not Found! Please change your search criteria!!"
      status_code  = "404"
    }
  }

  condition {
    path_pattern {
      values = ["/error"]
    }
  }
}


output "target_group_arn" {
  value = aws_lb_target_group.target-group.arn
}

output "lb_id" {
  value = aws_alb.a_alb.id
}
