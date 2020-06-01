resource "aws_cloudwatch_log_group" "mongodb" {
  name = "/ecs/mongodb"
  tags = var.tags
}

resource "aws_efs_file_system" "mongodb" {
  tags = merge(var.tags, { "Name" = "ecs-mongodb-data" })
}

resource "aws_efs_mount_target" "mount_az1" {
  file_system_id  = aws_efs_file_system.mongodb.id
  subnet_id       = aws_default_subnet.default_az1.id
  security_groups = [aws_security_group.efs_mongodb_access.id]
}

resource "aws_efs_mount_target" "mount_az2" {
  file_system_id  = aws_efs_file_system.mongodb.id
  subnet_id       = aws_default_subnet.default_az2.id
  security_groups = [aws_security_group.efs_mongodb_access.id]
}

resource "aws_efs_mount_target" "mount_az3" {
  file_system_id  = aws_efs_file_system.mongodb.id
  subnet_id       = aws_default_subnet.default_az3.id
  security_groups = [aws_security_group.efs_mongodb_access.id]
}

resource "aws_ecs_cluster" "mongodb" {
  name = "mongodb"
  tags = var.tags
}

resource "aws_ecs_task_definition" "mongodb" {
  family                   = "mongodb-4"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  volume {
    name = "efs-mongodb-data"
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.mongodb.id
    }
  }
  tags                  = var.tags
  container_definitions = <<TASK_CONTAINER_DEFINITION
[
  {
    "name": "mongodb-container",
    "image": "mongo:4.0",
    "command": ["--quiet"],
    "essential": true,
    "portMappings": [
      {
        "protocol": "tcp",
        "containerPort": 27017,
        "hostPort": ${var.db_port}
      }
    ],
    "environment": [
      {
        "name": "MONGO_INITDB_ROOT_USERNAME",
        "value": "${var.db_root_username}"
      },
      {
        "name": "MONGO_INITDB_ROOT_PASSWORD",
        "value": "${var.db_root_password}"
      }
    ],
    "mountPoints": [
      {
        "containerPath": "/data/db",
        "sourceVolume": "efs-mongodb-data"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${aws_cloudwatch_log_group.mongodb.name}",
        "awslogs-region": "${var.region}",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
TASK_CONTAINER_DEFINITION
}

resource "aws_ecs_service" "mongodb" {
  depends_on                         = [aws_lb_listener.mongodb]
  name                               = "mongodb-service"
  cluster                            = aws_ecs_cluster.mongodb.id
  launch_type                        = "FARGATE"
  platform_version                   = "1.4.0"
  task_definition                    = aws_ecs_task_definition.mongodb.arn
  desired_count                      = 1
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  force_new_deployment               = true

  network_configuration {
    security_groups  = [aws_security_group.mongodb.id]
    subnets          = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id, aws_default_subnet.default_az3.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.mongodb.id
    container_name   = jsondecode(aws_ecs_task_definition.mongodb.container_definitions)[0].name
    container_port   = jsondecode(aws_ecs_task_definition.mongodb.container_definitions)[0].portMappings[0].containerPort
  }

  tags = var.tags
}
