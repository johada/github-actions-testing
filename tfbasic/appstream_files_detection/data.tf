data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "role_policy" {
  statement {
    effect = "Allow"

    actions   = ["logs:CreateLogGroup"]
    resources = ["arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:*"]
  }
  statement {
    effect = "Allow"

    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${module.aws_lambda_function.function_name}:*"]
  }
  statement {
    effect = "Allow"

    actions   = ["dynamodb:DeleteItem", "dynamodb:PutItem", "dynamodb:UpdateItem", "dynamodb:GetItem", "dynamodb:Query", "dynamodb:Scan"]
    resources = ["arn:aws:dynamodb:${var.region}:${data.aws_caller_identity.current.account_id}:table/${module.aws_dynamodb_table.id}"]
  }

  statement {
    effect = "Allow"

    actions   = ["kms:Encrypt", "kms:Decrypt"]
    resources = ["arn:aws:kms:${var.region}:${data.aws_caller_identity.current.account_id}:key/${module.aws_dynamodb_table.kms_key_id}"]
  }
}

data "aws_s3_bucket" "appstream_bucket" {
  bucket = "appstream-36fb080bb8-${var.region}-${data.aws_caller_identity.current.account_id}"
}

