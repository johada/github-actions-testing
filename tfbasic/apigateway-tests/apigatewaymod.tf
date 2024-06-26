# data "archive_file" "lambda_package" {
#   type        = "zip"
#   source_file = "index.js"
#   output_path = "index.zip"

# }


# data "aws_iam_policy_document" "example_cloudwatch_assume_role" {
#   statement {
#     effect = "Allow"

#     principals {
#       type        = "Service"
#       identifiers = ["apigateway.amazonaws.com"]
#     }

#     actions = ["sts:AssumeRole"]
#   }
# }
# resource "aws_cloudwatch_log_group" "example" {
#   name              = "log-group-troubleshhoting"
#   retention_in_days = 7

#   tags = merge(local.tags, { Capability = "Example" })
# }


# resource "aws_iam_role" "example_cloudwatch" {
#   name               = "api-gateway-cloudwatch-role-troubleshhoting"
#   assume_role_policy = data.aws_iam_policy_document.example_cloudwatch_assume_role.json
# }

# data "aws_iam_policy_document" "example_cloudwatch" {
#   statement {
#     effect = "Allow"

#     actions = [
#       "logs:CreateLogGroup",
#       "logs:CreateLogStream",
#       "logs:DescribeLogGroups",
#       "logs:DescribeLogStreams",
#       "logs:PutLogEvents",
#       "logs:GetLogEvents",
#       "logs:FilterLogEvents",
#     ]

#     resources = ["*"]
#   }
# }

# resource "aws_iam_role_policy" "cloudwatch" {
#   name   = "policy-cloudwatch-troubleshhoting"
#   role   = aws_iam_role.example_cloudwatch.id
#   policy = data.aws_iam_policy_document.example_cloudwatch.json
# }


# resource "aws_iam_role" "lambda_role" {
#   name = "lambda-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action = "sts:AssumeRole",
#         Effect = "Allow",
#         Principal = {
#           Service = "lambda.amazonaws.com"
#         }
#       }
#     ]
#   })
# }

# resource "aws_lambda_function" "html_lambda" {
#   filename         = "index.zip"
#   function_name    = "troubleshhoting_lambda"
#   role             = aws_iam_role.lambda_role.arn
#   handler          = "index.handler"
#   runtime          = "nodejs20.x"
#   source_code_hash = data.archive_file.lambda_package.output_base64sha256

# }

# resource "aws_iam_role_policy_attachment" "lambda_basic" {

#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
#   role       = aws_iam_role.lambda_role.name

# }

# module "aws_api_gateway" {
#   source = "git::git@github.com:Rockwell-Automation-Inc/terraform-aws-api-gateway-module.git?ref=feature/fixUpdateStages"

#   api_name                                  = "troubleshhoting"
#   is_open_api                               = false
#   path_part                                 = "validate"
#   stage_name                                = "prod"
#   deployment_description                    = "Deployed at ${timestamp()}"
#   stage_description                         = timestamp()
#   stage_access_log_settings_destination_arn = aws_cloudwatch_log_group.example.arn
#   cloudwatch_role_arn                       = aws_iam_role.example_cloudwatch.arn
#   endpoint_type                             = "PRIVATE"
#   api_custom_policy                         = data.aws_iam_policy_document.api_gateway_troubleshooting.json

#   method_request_map = {
#     POST = {}
#   }

#   integration_map = {
#     POST = {
#       type                    = "AWS_PROXY"
#       integration_http_method = "POST"
#       uri                     = aws_lambda_function.html_lambda.invoke_arn
#     }
#   }

#   method_response_map = {
#     POST = {
#       status_code = "200"
#       response_models = {
#         "application/json" = "Empty"
#       }
#       response_parameters = {
#         "method.response.header.Access-Control-Allow-Origin" = true
#       }
#     }
#   }

#   # Tags.
#   tags = merge(local.tags, { Capability = "Example" })
# }

# resource "aws_lambda_permission" "apigw_lambda" {

#   statement_id  = "AllowExecutionFromAPIGateway"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.html_lambda.function_name
#   principal     = "apigateway.amazonaws.com"
#   source_arn    = "${module.aws_api_gateway.api_gateway_execution_arn}*/POST/validate"

# }

# data "aws_iam_policy_document" "api_gateway_troubleshooting" {
#   statement {
#     effect = "Allow"

#     principals {
#       type        = "AWS"
#       identifiers = ["*"]
#     }

#     actions   = ["execute-api:Invoke"]
#     resources = ["arn:aws:execute-api:us-east-1:123964965926:${module.aws_api_gateway.api_gateway_id}/prod/POST/"]

#   }
# }