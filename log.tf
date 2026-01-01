locals {
  log_group_name = "${var.service_name}-${var.environment}-${var.worker_name}-logs"
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "log-group" {
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions = [
      "kms:*"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    sid    = "${title(var.service_name)}${title(var.environment)}${title(var.worker_name)}LogGroupPolicy"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["logs.us-east-1.amazonaws.com"]
    }

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*",
      "kms:Get*",
      "kms:List*",
    ]

    resources = ["*"]

    condition {
      test     = "ForAnyValue:ArnEquals"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values   = ["arn:aws:logs:us-east-1:${data.aws_caller_identity.current.account_id}:log-group:${local.log_group_name}"]
    }
  }
}

resource "aws_kms_key" "log-group" {
  description = "KMS Key for ${var.service_name} (${var.worker_name}) logs in ${var.environment}"
  policy      = data.aws_iam_policy_document.log-group.json
}

resource "aws_cloudwatch_log_group" "log-group" {
  name = local.log_group_name

  kms_key_id        = aws_kms_key.log-group.arn
  retention_in_days = 7
  log_group_class   = "STANDARD"

  tags = {
    Service = var.service_name
    Worker  = var.worker_name
  }
}