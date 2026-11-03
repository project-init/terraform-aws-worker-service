mock_provider "aws" {
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = <<-JSON
          {
            "Version": "2012-10-17",
            "Statement": [{
              "Effect": "Allow",
              "Action": "sts:AssumeRole",
              "Principal": {
                "Service": "ecs-tasks.amazonaws.com"
              }
            }]
          }
        JSON
    }
  }

  mock_data "aws_region" {
    defaults = {
      region = "us-east-1"
    }
  }

  mock_data "aws_ecs_task_definition" {
    defaults = {
      revision = 1
    }
  }

  mock_resource "aws_iam_role" {
    defaults = {
      arn = "arn:aws:iam::123456789012:role/test-worker"
    }
  }

  mock_resource "aws_iam_policy" {
    defaults = {
      arn = "arn:aws:iam::123456789012:policy/test-worker"
    }
  }

  mock_resource "aws_kms_key" {
    defaults = {
      arn = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
    }
  }
}

variables {
  environment      = "test"
  ecs_cluster_arn  = "arn:aws:ecs:us-east-1:123456789012:cluster/test"
  ecs_cluster_name = "test"
  worker_name      = "worker"
  service_name     = "service"
  subnets          = ["subnet-12345678"]
  security_groups  = []
  image            = "example/worker:test"
  vpc_id           = "vpc-12345678"
}

run "default_sets_no_health_check" {
  command = apply

  assert {
    condition     = !contains(keys(jsondecode(aws_ecs_task_definition.worker.container_definitions)[0]), "healthCheck")
    error_message = "Omitting health_check must leave the container without one."
  }

  assert {
    condition     = jsondecode(aws_ecs_task_definition.worker.container_definitions)[0].image == "example/worker:test"
    error_message = "The container must keep its image."
  }
}

run "health_check_uses_ecs_defaults" {
  command = apply

  variables {
    health_check = {
      command = ["CMD", "/usr/bin/app", "healthcheck"]
    }
  }

  assert {
    condition = jsondecode(aws_ecs_task_definition.worker.container_definitions)[0].healthCheck == {
      command  = ["CMD", "/usr/bin/app", "healthcheck"]
      interval = 30
      timeout  = 5
      retries  = 3
    }
    error_message = "A health check with only a command must take ECS's defaults and leave startPeriod unset."
  }
}

run "health_check_passes_every_setting" {
  command = apply

  variables {
    health_check = {
      command      = ["CMD", "/usr/bin/app", "healthcheck"]
      interval     = 10
      timeout      = 2
      retries      = 6
      start_period = 15
    }
  }

  assert {
    condition = jsondecode(aws_ecs_task_definition.worker.container_definitions)[0].healthCheck == {
      command     = ["CMD", "/usr/bin/app", "healthcheck"]
      interval    = 10
      timeout     = 2
      retries     = 6
      startPeriod = 15
    }
    error_message = "The container must carry every health check setting."
  }
}

run "health_check_rejects_interval_below_5" {
  command = plan

  variables {
    health_check = {
      command  = ["CMD", "/usr/bin/app", "healthcheck"]
      interval = 4
    }
  }

  expect_failures = [var.health_check]
}

run "health_check_rejects_interval_above_300" {
  command = plan

  variables {
    health_check = {
      command  = ["CMD", "/usr/bin/app", "healthcheck"]
      interval = 301
    }
  }

  expect_failures = [var.health_check]
}

run "health_check_rejects_a_fractional_interval" {
  command = plan

  variables {
    health_check = {
      command  = ["CMD", "/usr/bin/app", "healthcheck"]
      interval = 5.5
    }
  }

  expect_failures = [var.health_check]
}

run "health_check_rejects_timeout_below_2" {
  command = plan

  variables {
    health_check = {
      command = ["CMD", "/usr/bin/app", "healthcheck"]
      timeout = 1
    }
  }

  expect_failures = [var.health_check]
}

run "health_check_rejects_timeout_above_60" {
  command = plan

  variables {
    health_check = {
      command = ["CMD", "/usr/bin/app", "healthcheck"]
      timeout = 61
    }
  }

  expect_failures = [var.health_check]
}

run "health_check_rejects_a_fractional_timeout" {
  command = plan

  variables {
    health_check = {
      command = ["CMD", "/usr/bin/app", "healthcheck"]
      timeout = 2.5
    }
  }

  expect_failures = [var.health_check]
}

run "health_check_rejects_retries_below_1" {
  command = plan

  variables {
    health_check = {
      command = ["CMD", "/usr/bin/app", "healthcheck"]
      retries = 0
    }
  }

  expect_failures = [var.health_check]
}

run "health_check_rejects_retries_above_10" {
  command = plan

  variables {
    health_check = {
      command = ["CMD", "/usr/bin/app", "healthcheck"]
      retries = 11
    }
  }

  expect_failures = [var.health_check]
}

run "health_check_rejects_a_fractional_retries" {
  command = plan

  variables {
    health_check = {
      command = ["CMD", "/usr/bin/app", "healthcheck"]
      retries = 1.5
    }
  }

  expect_failures = [var.health_check]
}

run "health_check_rejects_start_period_below_0" {
  command = plan

  variables {
    health_check = {
      command      = ["CMD", "/usr/bin/app", "healthcheck"]
      start_period = -1
    }
  }

  expect_failures = [var.health_check]
}

run "health_check_rejects_start_period_above_300" {
  command = plan

  variables {
    health_check = {
      command      = ["CMD", "/usr/bin/app", "healthcheck"]
      start_period = 301
    }
  }

  expect_failures = [var.health_check]
}

run "health_check_rejects_a_fractional_start_period" {
  command = plan

  variables {
    health_check = {
      command      = ["CMD", "/usr/bin/app", "healthcheck"]
      start_period = 0.5
    }
  }

  expect_failures = [var.health_check]
}

run "health_check_rejects_a_command_without_a_type" {
  command = plan

  variables {
    health_check = {
      command = ["/usr/bin/app", "healthcheck"]
    }
  }

  expect_failures = [var.health_check]
}

run "health_check_rejects_a_type_without_a_command" {
  command = plan

  variables {
    health_check = {
      command = ["CMD"]
    }
  }

  expect_failures = [var.health_check]
}

run "health_check_rejects_none" {
  command = plan

  variables {
    health_check = {
      command = ["NONE"]
    }
  }

  expect_failures = [var.health_check]
}

run "health_check_rejects_an_empty_command" {
  command = plan

  variables {
    health_check = {
      command = []
    }
  }

  expect_failures = [var.health_check]
}

run "health_check_rejects_a_null_command" {
  command = plan

  variables {
    health_check = {
      command = null
    }
  }

  expect_failures = [var.health_check]
}

run "health_check_accepts_cmd_shell" {
  command = plan

  variables {
    health_check = {
      command = ["CMD-SHELL", "/usr/bin/app healthcheck"]
    }
  }
}
