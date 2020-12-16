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

resource "aws_security_group" "sg_alb" {
  name   = "${local.name}-alb"
  vpc_id = aws_default_vpc.default.id
  tags   = var.tags

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "sg_ecs" {
  name   = "${local.name}-ecs"
  vpc_id = aws_default_vpc.default.id
  tags   = var.tags

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "TCP"
    security_groups = [aws_security_group.sg_alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
