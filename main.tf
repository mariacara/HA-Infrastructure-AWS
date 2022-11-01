data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

# Create the launching configuration for webserver cluster
resource "aws_launch_configuration" "webcluster" {
  image_id        = var.ami
  instance_type   = var.instance_type
  key_name        = var.key
  security_groups = [var.sg]

  lifecycle {
    create_before_destroy = true
  }
}

# Create autoscaling group
resource "aws_autoscaling_group" "asg" {
  launch_configuration = aws_launch_configuration.webcluster.name
  vpc_zone_identifier  = data.aws_subnet_ids.default.ids
  target_group_arns    = [aws_lb_target_group.asg-tg.arn]
  health_check_type    = "ELB"
  desired_capacity     = 2
  min_size             = 2
  max_size             = 2
  tag {
    key                 = "Name"
    value               = "asg"
    propagate_at_launch = true
  }
}

# Create Application Load Balancer ALB
resource "aws_lb" "loadbalancer" {
  name               = "loadbalancer"
  load_balancer_type = "application"
  subnets            = data.aws_subnet_ids.default.ids
  security_groups    = [var.sg]
}

# Create load balancer listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.loadbalancer.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}
# Create target group
resource "aws_lb_target_group" "asg-tg" {
  name     = "asg-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Create listener rule
resource "aws_lb_listener_rule" "asg-listen" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100
  condition {
    path_pattern {
      values = ["*"]
    }
  }
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg-tg.arn
  }
}