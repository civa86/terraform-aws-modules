resource "aws_default_vpc" "default" {}

resource "aws_default_subnet" "default_az1" {
  availability_zone = "${var.region}a"
}
resource "aws_default_subnet" "default_az2" {
  availability_zone = "${var.region}b"
}
resource "aws_default_subnet" "default_az3" {
  availability_zone = "${var.region}c"
}

resource "aws_security_group" "mongodb" {
  name   = "ecs-mongodb"
  vpc_id = aws_default_vpc.default.id
  ingress {
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = var.tags
}

resource "aws_security_group" "efs_mongodb_access" {
  name   = "efs-mongodb-data"
  vpc_id = aws_default_vpc.default.id
  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.mongodb.id]
  }
  tags = var.tags
}

resource "aws_lb" "mongodb" {
  name               = "ecs-mongodb-lb"
  internal           = false
  load_balancer_type = "network"
  subnets            = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id, aws_default_subnet.default_az3.id]
  tags               = var.tags
}

resource "aws_lb_listener" "mongodb" {
  load_balancer_arn = aws_lb.mongodb.arn
  port              = var.db_port
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mongodb.arn
  }
}

resource "aws_lb_target_group" "mongodb" {
  name        = "ecs-mongodb-target"
  port        = var.db_port
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = aws_default_vpc.default.id

  lifecycle {
    create_before_destroy = true
  }

  health_check {
    protocol            = "TCP"
    port                = var.db_port
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 30
  }

  tags = var.tags
}
