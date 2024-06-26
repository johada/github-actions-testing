# #Lambda policies and roles
# resource "aws_iam_role" "iam_for_lambda" {
#   name               = "test-lambda-role-for-token-validation-${var.region}"
#   assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
# }

# resource "aws_iam_policy" "policy" {
#   name        = "test-lambda-policy-token-validation-${var.region}"
#   description = "A policy to allow lambda to write logs"
#   policy      = data.aws_iam_policy_document.lambda_role_policy.json
# }

# resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
#   role       = aws_iam_role.iam_for_lambda.name
#   policy_arn = aws_iam_policy.policy.arn
# }


# #Cloudwatch policies and roles

# resource "aws_iam_role" "iam_for_cloudwatch" {
#   name               = "test-api-gateway-cloudwatch-role-${var.region}"
#   assume_role_policy = data.aws_iam_policy_document.cloudwatch_assume_role.json
# }

# resource "aws_iam_policy" "cloudwatch_policy" {
#   name        = "test-cloudwatch-policy-token-validation-${var.region}"
#   description = "A policy to allow Cloudwatch to write logs"
#   policy      = data.aws_iam_policy_document.cloudwatch_role_policy.json
# }

# resource "aws_iam_role_policy_attachment" "cloudwatch_policy_attachment" {
#   role       = aws_iam_role.iam_for_cloudwatch.name
#   policy_arn = aws_iam_policy.cloudwatch_policy.arn

# }


# # #API Gateway policies and roles
# # resource "aws_api_gateway_rest_api_policy" "policy_for_api" {
# #   rest_api_id = module.aws_api_gateway.api_gateway_id
# #   policy      = data.aws_iam_policy_document.api_gateway_policy.json

# #   lifecycle {
# #     ignore_changes = [policy]
# #   }
# #   depends_on = [module.aws_api_gateway]  

# # }

# resource "aws_cloudwatch_log_group" "api_gateway_log_group" {
#   # name              = "API-Gateway-Execution-Logs-${module.aws_api_gateway.api_gateway_id}/${module.aws_api_gateway.api_gateway_stage_id}"
#   name              = "API-Gateway-Execution-Logs-${var.region}"
#   retention_in_days = 7

#   tags = var.tags
# }

# module "aws_api_gateway"{
#     source = "git::git@github.com:Rockwell-Automation-Inc/terraform-aws-api-gateway-module.git?ref=v0.0.5"

#   api_name                                  = "test-validate-token-api-${var.region}"
#   is_open_api                               = false
#   path_part                                 = "validate"
#   stage_name                                = "live"
#   stage_access_log_settings_destination_arn = aws_cloudwatch_log_group.api_gateway_log_group.arn
#   cloudwatch_role_arn                       = aws_iam_role.iam_for_cloudwatch.arn
#   endpoint_type                             = "REGIONAL"

#   method_request_map = {
#     POST = {}
#   }

#   integration_map = {
#     POST = {
#       type = "AWS_PROXY"
#       integration_http_method = "POST"
#       uri  = module.aws_lambda_function.invoke_arn
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

# # Tags.
#     tags = var.tags
# }


# module "aws_lambda_function" {

#   source = "git::git@github.com:Rockwell-Automation-Inc/terraform-aws-lambda-function-module.git?ref=v0.0.11"

#   lambda_function_file    = "${path.module}/lambda_function.py"
#   lambda_function_name    = "test-token-validation-${var.region}"
#   lambda_function_role    = aws_iam_role.iam_for_lambda.arn
#   lambda_function_handler = "lambda_function.lambda_handler"
#   lambda_function_runtime = "python3.9"

#   # Tags.
#   tags = var.tags

#   tracing_config = {
#     mode = "Active"
#   }
# }

# resource "aws_lambda_permission" "allow_api_gateway" {
#   function_name = module.aws_lambda_function.function_name
#   statement_id  = "AllowExecutionFromApiGateway-${var.region}"
#   action        = "lambda:InvokeFunction"
#   principal     = "apigateway.amazonaws.com"
#   source_arn = "${module.aws_api_gateway.api_gateway_execution_arn}*"

#   depends_on    = [module.aws_api_gateway]
# }



# module "aws_dynamodb_table" {
#   source = "git::git@github.com:Rockwell-Automation-Inc/terraform-aws-dynamodb-module.git?ref=v0.0.4"

#   dynamodb_table_name                    = "test-token-validation-table"
#   hash_key                               = "pk"
#   range_key                              = "sk"
#   read_capacity                          = 1
#   write_capacity                         = 1
#   auto_scaling_enabled                   = true
#   auto_scaling_read_min_capacity         = 1
#   auto_scaling_read_max_capacity         = 10
#   auto_scaling_write_min_capacity        = 1
#   auto_scaling_write_max_capacity        = 10
#   aws_appautoscaling_policy_target_value = 70
#   deletion_protection_enabled            = false
#   ttl_attribute_name                     = "TimeToExist"
#   ttl_enabled                            = true
#   point_in_time_recovery_enabled         = false

#   attributes = [
#     {
#       name = "pk"
#       type = "S"
#     },
#     {
#       name = "sk"
#       type = "S"
#     }
#   ]
#   # Tags.
#   tags = var.tags
# }




