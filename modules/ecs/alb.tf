resource "aws_lb" "ingress" {
  name               = local.name
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id, aws_default_subnet.default_az3.id]
  security_groups    = [aws_security_group.sg_alb.id]
  tags               = var.tags
}

resource "aws_lb_target_group" "http" {
  name        = "${local.name}-http"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_default_vpc.default.id

  lifecycle {
    create_before_destroy = true
  }

  health_check {
    path = "/healthcheck"
  }

  tags = var.tags
}

resource "aws_lb_listener" "entrypoint" {
  load_balancer_arn = aws_lb.ingress.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# Any route will authenticate users with cognito at infrastructure level
resource "aws_lb_listener" "ssl_entrypoint" {
  load_balancer_arn = aws_lb.ingress.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.default.arn

  default_action {
    type = "authenticate-cognito"

    authenticate_cognito {
      user_pool_arn              = aws_cognito_user_pool.default.arn
      user_pool_client_id        = aws_cognito_user_pool_client.default.id
      user_pool_domain           = aws_cognito_user_pool_domain.default.domain
      on_unauthenticated_request = "authenticate"
      scope                      = "openid"
    }
  }

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.http.arn
  }
}

# API will receive JWT and will authenticate and authorize users by themselves at application level
resource "aws_lb_listener_rule" "api" {
  listener_arn = aws_lb_listener.ssl_entrypoint.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.http.arn
  }

  condition {
    path_pattern {
      values = ["/api", "/api/*"]
    }
  }
}




