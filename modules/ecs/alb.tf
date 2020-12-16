resource "aws_lb" "ingress" {
  name               = "${var.project_name}-${terraform.workspace}"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id, aws_default_subnet.default_az3.id]
  security_groups    = [aws_security_group.sg_alb.id]
  tags               = var.tags
}

resource "aws_lb_target_group" "default" {
  name        = "${var.project_name}-${terraform.workspace}-default"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_default_vpc.default.id

  lifecycle {
    create_before_destroy = true
  }

  health_check {
    path = "/"
  }

  tags = var.tags
}

resource "aws_lb_listener" "entrypoint" {
  load_balancer_arn = aws_lb.ingress.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.default.arn
  }
}
