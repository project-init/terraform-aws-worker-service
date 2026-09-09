resource "aws_iam_role" "service" {
  name               = "${var.service_name}-${var.worker_name}-execution-task-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  tags = {
    Name        = "${var.service_name}-${var.worker_name}-iam-role"
    Environment = var.environment
  }
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ecs_exec_policy" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "ssm:StartSession",
      "ssm:DescribeSessions",
      "ssm:TerminateSession",
      "ecs:ExecuteCommand",
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "ecs_exec_policy" {
  name   = "${var.service_name}-ecs-exec-policy"
  policy = data.aws_iam_policy_document.ecs_exec_policy.json
}

resource "aws_iam_role_policy_attachment" "service_policy" {
  role       = aws_iam_role.service.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ecs_exec_policy" {
  role       = aws_iam_role.service.name
  policy_arn = aws_iam_policy.ecs_exec_policy.arn
}

resource "aws_iam_role_policy" "service" {
  for_each = var.iam_policies

  name   = each.key
  role   = aws_iam_role.service.name
  policy = each.value
}
