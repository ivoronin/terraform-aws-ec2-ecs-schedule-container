data "aws_region" "current" {}

resource "aws_ecs_task_definition" "task" {
  family                   = var.name_prefix
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.runner.arn
  cpu                      = 256
  memory                   = 512

  container_definitions = jsonencode([merge(var.container_definition, {
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.log_group.name
        awslogs-region        = data.aws_region.current.name
        awslogs-stream-prefix = "fargate"
      }
    }
  })])

  dynamic "volume" {
    for_each = var.efs_volumes

    content {
      name = volume.value["name"]

      efs_volume_configuration {
        file_system_id = volume.value["file_system_id"]
      }
    }
  }
}

resource "aws_cloudwatch_log_group" "log_group" {
  name_prefix       = var.name_prefix
  retention_in_days = var.log_retention_in_days
}

resource "aws_cloudwatch_event_rule" "rule" {
  name_prefix         = "${var.name_prefix}-"
  schedule_expression = "cron(${var.cron})"
}

resource "aws_cloudwatch_event_target" "target" {
  rule = aws_cloudwatch_event_rule.rule.name
  arn  = var.ecs_cluster_arn

  role_arn = aws_iam_role.scheduler.arn

  ecs_target {
    task_count          = 1
    task_definition_arn = aws_ecs_task_definition.task.arn
    launch_type         = "FARGATE"
    platform_version    = "LATEST"

    network_configuration {
      assign_public_ip = true
      security_groups  = var.security_groups
      subnets          = var.subnets
    }
  }
}