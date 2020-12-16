data "aws_iam_policy_document" "ecs_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.project_name}-${terraform.workspace}-ecs-task-exec-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# data "aws_iam_policy_document" "autoscale_assume_role_policy" {
#   statement {
#     actions = ["sts:AssumeRole"]

#     principals {
#       type        = "Service"
#       identifiers = ["ecs.application-autoscaling.amazonaws.com"]
#     }
#   }
# }

# data "aws_iam_policy_document" "autoscale_policy" {
#   statement {
#     actions = [
#       "ecs:DescribeServices",
#       "ecs:UpdateService",
#       "cloudwatch:PutMetricAlarm",
#       "cloudwatch:DescribeAlarms",
#       "cloudwatch:DeleteAlarms"
#     ]
#     resources = ["*"]
#   }
# }

# resource "aws_iam_role" "autoscaling" {
#   name               = "${var.project_name}-${terraform.workspace}-appautoscaling-role"
#   assume_role_policy = data.aws_iam_policy_document.autoscale_assume_role_policy.json
# }

# resource "aws_iam_role_policy" "autoscaling" {
#   name   = "${var.project_name}-${terraform.workspace}-appautoscaling-policy"
#   policy = data.aws_iam_policy_document.autoscale_policy.json
#   role   = aws_iam_role.autoscaling.id
# }
