resource "aws_iam_role" "runner" {
  name_prefix = "${var.name_prefix}-runner-"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })

  inline_policy {
    name = "runner"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
          Effect = "Allow"
          Resource = [
            "${aws_cloudwatch_log_group.log_group.arn}:*"
          ]
        }
      ]
    })
  }
}

resource "aws_iam_role" "scheduler" {
  name_prefix = "${var.name_prefix}-scheduler-"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "events.amazonaws.com"
        }
      },
    ]
  })

  inline_policy {
    name = "scheduler"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "ecs:RunTask"
          ]
          Effect = "Allow"
          Resource = [
            aws_ecs_task_definition.task.arn,
          ]
        },
        // This is required to assign a role to a task
        {
          Effect   = "Allow",
          Action   = ["iam:PassRole"],
          Resource = aws_iam_role.runner.arn
        }
      ]
    })
  }
}
