locals {
  http_service_name = "${var.project_name}-http-${terraform.workspace}"
}

resource "aws_ecs_cluster" "default" {
  name = "${var.project_name}-${terraform.workspace}"
  tags = var.tags
}

resource "aws_cloudwatch_log_group" "http" {
  name = "/ecs/${var.project_name}-http-${terraform.workspace}"
  tags = var.tags
}

resource "aws_ecs_task_definition" "http" {
  family                   = local.http_service_name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  tags                     = var.tags
  container_definitions    = <<TASK_CONTAINER_DEFINITION
[
  {
    "name": "${local.http_service_name}",
    "image": "mendhak/http-https-echo:15",
    "essential": true,
    "portMappings": [
      {
        "protocol": "tcp",
        "containerPort": 8080,
        "hostPort": 8080
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${aws_cloudwatch_log_group.http.name}",
        "awslogs-region": "${var.region}",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
TASK_CONTAINER_DEFINITION
}

resource "aws_ecs_service" "http_service" {
  depends_on                         = [aws_lb_listener.entrypoint]
  name                               = local.http_service_name
  cluster                            = aws_ecs_cluster.default.id
  launch_type                        = "FARGATE"
  platform_version                   = "1.4.0"
  task_definition                    = aws_ecs_task_definition.http.arn
  desired_count                      = var.replicas
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  force_new_deployment               = true
  tags                               = var.tags
  propagate_tags                     = "SERVICE"
  network_configuration {
    security_groups  = [aws_security_group.sg_ecs.id]
    subnets          = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id, aws_default_subnet.default_az3.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.default.id
    container_name   = jsondecode(aws_ecs_task_definition.http.container_definitions)[0].name
    container_port   = 8080
  }

}

resource "aws_appautoscaling_target" "default" {
  max_capacity       = var.auto_scaling_max_replicas
  min_capacity       = var.replicas
  resource_id        = "service/${aws_ecs_cluster.default.name}/${local.http_service_name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  depends_on = [aws_ecs_service.http_service]
}

resource "aws_appautoscaling_policy" "default" {
  name               = "${local.http_service_name}-autoscaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.default.resource_id
  scalable_dimension = aws_appautoscaling_target.default.scalable_dimension
  service_namespace  = aws_appautoscaling_target.default.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = var.auto_scaling_max_cpu_util

    scale_in_cooldown  = 300
    scale_out_cooldown = 300

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }

  depends_on = [aws_appautoscaling_target.default]
}
