data "aws_region" "current" {}

locals {
  task_env_variables = concat(var.environment_variables, [
    { name : "ENV", value : var.environment },
    // This is a commonly overlooked variable as it is needed to have your aws default config correctly manage the region.
    { name : "AWS_REGION", value : data.aws_region.current.region }
  ])
}

resource "aws_ecs_task_definition" "worker" {
  family = "${var.service_name}-${var.environment}-worker-${var.worker_name}"

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }

  container_definitions = <<DEFINITION
  [
    {
      "name": "main",
      "image": "${var.image}",
      "entryPoint": [],
      "environment": ${jsonencode(local.task_env_variables)},
      "secrets": ${jsonencode(var.secrets)},
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.log-group.id}",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "${var.service_name}-${var.environment}"
        }
      },
      "cpu": ${var.cpu},
      "memory": ${var.memory},
      "networkMode": "awsvpc"
    }
  ]
  DEFINITION

  requires_compatibilities = [var.use_ec2 ? "EC2" : "FARGATE"]
  network_mode             = "awsvpc"
  memory                   = var.memory
  cpu                      = var.cpu
  execution_role_arn       = aws_iam_role.service.arn
  task_role_arn            = aws_iam_role.service.arn

  tags = {
    Name = "${var.service_name}-${var.environment}-worker-${var.worker_name}"
  }
}

data "aws_ecs_task_definition" "main" {
  task_definition = aws_ecs_task_definition.worker.family
}

resource "aws_ecs_service" "aws-ecs-service" {
  name                   = var.service_name
  cluster                = var.ecs_cluster_arn
  task_definition        = "${aws_ecs_task_definition.worker.family}:${max(aws_ecs_task_definition.worker.revision, data.aws_ecs_task_definition.main.revision)}"
  desired_count          = var.desired_count
  force_new_deployment   = var.force_new_deployment
  enable_execute_command = true
  launch_type            = var.use_ec2 ? "EC2" : "FARGATE"
  propagate_tags         = "SERVICE"

  dynamic "capacity_provider_strategy" {
    for_each = var.capacity_providers
    content {
      capacity_provider = capacity_provider_strategy.value.capacity_provider
      base              = capacity_provider_strategy.value.base
      weight            = capacity_provider_strategy.value.weight
    }
  }

  dynamic "ordered_placement_strategy" {
    for_each = var.ordered_placement_strategies
    content {
      type  = ordered_placement_strategy.value.type
      field = ordered_placement_strategy.value.field
    }
  }

  network_configuration {
    subnets          = var.subnets
    assign_public_ip = false
    security_groups  = concat([aws_security_group.service.id], var.security_groups)
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}