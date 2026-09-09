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

run "default_creates_no_policies" {
  command = plan

  assert {
    condition     = length(aws_iam_role_policy.service) == 0
    error_message = "Omitting iam_policies must create no inline policies."
  }
}

run "empty_map_creates_no_policies" {
  command = plan

  variables {
    iam_policies = {}
  }

  assert {
    condition     = length(aws_iam_role_policy.service) == 0
    error_message = "An empty iam_policies map must create no inline policies."
  }
}

run "named_policies_attach_to_service_role" {
  command = plan

  variables {
    iam_policies = {
      read_objects = jsonencode({
        Version = "2012-10-17"
        Statement = [{
          Effect   = "Allow"
          Action   = ["s3:GetObject"]
          Resource = "arn:aws:s3:::example-workload/*"
        }]
      })
      list_bucket = jsonencode({
        Version = "2012-10-17"
        Statement = [{
          Effect   = "Allow"
          Action   = ["s3:ListBucket"]
          Resource = "arn:aws:s3:::example-workload"
        }]
      })
    }
  }

  assert {
    condition = (
      toset(keys(aws_iam_role_policy.service)) ==
      toset(["read_objects", "list_bucket"])
    )
    error_message = "Each map entry must create an inline policy."
  }

  assert {
    condition = alltrue([
      for name, policy in aws_iam_role_policy.service :
      policy.name == name
    ])
    error_message = "Inline policy names must match the map keys."
  }

  assert {
    condition = alltrue([
      for name, policy in aws_iam_role_policy.service :
      jsondecode(policy.policy) == jsondecode(var.iam_policies[name])
    ])
    error_message = "Each inline policy must preserve its supplied document."
  }

  assert {
    condition = alltrue([
      for policy in values(aws_iam_role_policy.service) :
      policy.role == aws_iam_role.service.name
    ])
    error_message = "All workload policies must attach to the service role."
  }
}