# terraform-aws-ec2-ecs-schedule-container
Schedules container runs on ECS Fargate using cron-like syntax

## How it works
This module creates a periodic event in EventBridge to schedule container runs

## Example
```hcl
module "backup" {
  source  = "ivoronin/ecs-schedule-container/aws"

  name_prefix     = "backup"
  cron            = "0 * ? * * *"

  efs_volumes = [{
    name           = "data"
    file_system_id = aws_efs_file_system.primary.id
  }]

  container_definition = {
    name      = "backup"
    image     = "restic/restic:latest"
    essential = true

    environment = [
      { name = "RESTIC_REPOSITORY", value = var.backup_restic_repository },
      { name = "RESTIC_PASSWORD", value = var.backup_restic_password }
    ]

    mountPoints = [{
        "containerPath" : local.backup_mount_point,
        "sourceVolume" : "data"
      }]

    command = [
      "backup",
      "--exclude-caches",
      "-H", "apps",
      "/data"
    ]
  }

  security_groups = [aws_security_group.backup.id]
  subnets         = [aws_subnet.app.id]
}
```