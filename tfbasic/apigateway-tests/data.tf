# # data "aws_caller_identity" "current" {}

# # #Lambda polices and roles
# data "aws_iam_policy_document" "lambda_assume_role" {
#   statement {
#     effect = "Allow"

#     principals {
#       type        = "Service"
#       identifiers = ["lambda.amazonaws.com"]
#     }

#     actions = ["sts:AssumeRole"]
#   }
# }


# data "aws_iam_policy_document" "lambda_role_policy" {
#   # statement {
#   #   effect = "Allow"

#   #   actions   = ["logs:CreateLogGroup"]
#   #   resources = ["arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:*"]
#   # }
#   # statement {
#   #   effect = "Allow"

#   #   actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
#   #   resources = ["arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${module.aws_lambda_function.function_name}:*"]
#   # }
#   statement {
#     effect = "Allow"

#     actions   = ["kms:Encrypt", "kms:Decrypt"]
#     resources = ["arn:aws:kms:us-east-1:123964965926:key/422859c3-e83f-4d95-8635-47c5be3da830"]
#     # resources = ["arn:aws:kms:${var.region}:${data.aws_caller_identity.current.account_id}:key/${module.aws_dynamodb_table.kms_key_id}"]
#   }
#   statement {
#     effect = "Allow"

#     actions   = ["dynamodb:Scan", "dynamodb:GetItem"]
#     resources = ["arn:aws:dynamodb:us-east-1:123964965926:table/token-validation-table"]
#   }

# }

# # #API Gateway polices and roles

# data "aws_iam_policy_document" "api_gateway_policy" {
#   statement {
#     effect = "Allow"

#     principals {
#       type        = "AWS"
#       identifiers = ["*"]
#     }
#     actions   = ["execute-api:Invoke"]
#     resources = ["arn:aws:execute-api:us-east-1:123964965926:qu2h6j6j4i/live/POST/"]

#   }
# }

# # #Cloudwatch polices and roles

# # data "aws_iam_policy_document" "cloudwatch_assume_role" {
# #   statement {
# #     effect = "Allow"

# #     principals {
# #       type        = "Service"
# #       identifiers = ["apigateway.amazonaws.com"]
# #     }

# #     actions = ["sts:AssumeRole"]
# #   }
# # }


# # data "aws_iam_policy_document" "cloudwatch_role_policy" {
# #   statement {
# #     effect = "Allow"

# #     actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:DescribeLogGroups", "logs:DescribeLogStreams", "logs:PutLogEvents", "logs:GetLogEvents", "logs:FilterLogEvents"]
# #     resources = ["arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:*"]
# #   }
# # }