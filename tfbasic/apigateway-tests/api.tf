# # #Lambda policies and roles
# resource "aws_iam_role" "iam_for_lambda" {
#   name               = "testing-token-validation"
#   assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
# }

# resource "aws_iam_policy" "policy" {
#   name        = "testing-token-validation"
#   description = "A policy to allow lambda to write logs"
#   policy      = data.aws_iam_policy_document.lambda_role_policy.json
# }

# resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
#   role       = aws_iam_role.iam_for_lambda.name
#   policy_arn = aws_iam_policy.policy.arn
# }


# # #Cloudwatch policies and roles

# # resource "aws_iam_role" "iam_for_cloudwatch" {
# #   name               = "api-gateway-cloudwatch-role-${var.region}"
# #   assume_role_policy = data.aws_iam_policy_document.cloudwatch_assume_role.json
# # }

# # resource "aws_iam_policy" "cloudwatch_policy" {
# #   name        = "test-cloudwatch-policy-token-validation-${var.region}"
# #   description = "A policy to allow Cloudwatch to write logs"
# #   policy      = data.aws_iam_policy_document.cloudwatch_role_policy.json
# # }

# # resource "aws_iam_role_policy_attachment" "cloudwatch_policy_attachment" {
# #   role       = aws_iam_role.iam_for_cloudwatch.name
# #   policy_arn = aws_iam_policy.cloudwatch_policy.arn
# # }


# # #✅
# # #API Gateway policies and roles
# resource "aws_api_gateway_rest_api_policy" "policy_for_api" {
#   rest_api_id = aws_api_gateway_rest_api.api.id
#   policy      = data.aws_iam_policy_document.api_gateway_policy.json

#   depends_on = [
#     aws_api_gateway_rest_api.api
#   ]
# }

# # #✅
# # resource "aws_cloudwatch_log_group" "api_gateway_log_group" {
# #   # name              = "API-Gateway-Execution-Logs-${module.aws_api_gateway.api_gateway_id}/${module.aws_api_gateway.api_gateway_stage_id}"
# #   name              = "API-Gateway-Execution-Logs-${var.region}"
# #   retention_in_days = 7

# #   tags = var.tags
# # }

# # # #✅
# resource "aws_api_gateway_rest_api" "api" {
#   name        = "testing-validate-token-api"
#   description = "This is the Validation token  API for testing purposes"

#   endpoint_configuration {
#     types = ["PRIVATE"]
#   }

# }
# # # #✅
# # # resource "aws_api_gateway_resource" "resource" {
# # #   rest_api_id = aws_api_gateway_rest_api.api.id
# # #   parent_id   = aws_api_gateway_rest_api.api.root_resource_id
# # #   path_part   = "validate"
# # # }

# # # #✅
# resource "aws_api_gateway_method" "post_method" {
#   rest_api_id   = aws_api_gateway_rest_api.api.id
#   resource_id   = aws_api_gateway_rest_api.api.root_resource_id
#   http_method   = "POST"
#   authorization = "NONE"
# }

# # # #✅
# resource "aws_api_gateway_integration" "integration" {
#   http_method             = aws_api_gateway_method.post_method.http_method
#   resource_id             = aws_api_gateway_rest_api.api.root_resource_id
#   rest_api_id             = aws_api_gateway_rest_api.api.id
#   integration_http_method = "POST"
#   type                    = "AWS_PROXY"
#   uri                     = module.aws_lambda_function.invoke_arn
# }

# resource "aws_api_gateway_method_response" "response_200" {
#   rest_api_id = aws_api_gateway_rest_api.api.id
#   resource_id = aws_api_gateway_rest_api.api.root_resource_id
#   http_method = aws_api_gateway_method.post_method.http_method
#   status_code = "200"

#     response_models = {
#     "application/json" = "Empty"
#   }

#     response_parameters = {
#     # "method.response.header.Access-Control-Allow-Headers" = true,
#     # "method.response.header.Access-Control-Allow-Methods" = true,
#     "method.response.header.Access-Control-Allow-Origin" = true

#   }
# }

# resource "aws_api_gateway_deployment" "deployment" {
#   rest_api_id = aws_api_gateway_rest_api.api.id
#   stage_name  = "live"

#   depends_on = [
#     aws_api_gateway_integration.integration
#   ]
# }

# # module "aws_api_gateway"{
# #     source = "git::git@github.com:Rockwell-Automation-Inc/terraform-aws-api-gateway-module.git?ref=v0.0.3"

# #   api_name                                  = "test-validate-token-api-${var.region}"
# #   is_open_api                               = false
# #   path_part                                 = "validate"
# #   stage_name                                = "live"
# #   stage_access_log_settings_destination_arn = aws_cloudwatch_log_group.api_gateway_log_group.arn
# #   cloudwatch_role_arn                       = aws_iam_role.iam_for_cloudwatch.arn
# #   endpoint_type                             = "REGIONAL"

# #   method_request_map = {
# #     POST = {}
# #   }

# #   integration_map = {
# #     POST = {
# #       type = "AWS_PROXY"
# #       integration_http_method = "POST"
# #       uri  = module.aws_lambda_function.invoke_arn
# #     }
# #   }

# #   method_response_map = {
# #     POST = {
# #       status_code = "200"
# #       response_models = {
# #         "application/json" = "Empty"
# #       }
# #       response_parameters = {
# #         "method.response.header.Access-Control-Allow-Origin" = true
# #       }
# #     }
# #   }

# # # Tags.
# #     tags = var.tags
# # }


# module "aws_lambda_function" {

#   source = "git::git@github.com:Rockwell-Automation-Inc/terraform-aws-lambda-function-module.git?ref=v0.0.11"

#   lambda_function_file    = "${path.module}/lambda_function.py"
#   lambda_function_name    = "testing-token-validation"
#   lambda_function_role    = aws_iam_role.iam_for_lambda.arn
#   lambda_function_handler = "lambda_function.lambda_handler"
#   lambda_function_runtime = "python3.9"

#   # Tags.
#   tags = {
#     Name = "testing-token-validation"
#   }

#   tracing_config = {
#     mode = "Active"
#   }
# }

# resource "aws_lambda_permission" "allow_api_gateway" {
#   function_name = module.aws_lambda_function.function_name
#   statement_id  = "AllowExecutionFromApiGateway-Testing"
#   action        = "lambda:InvokeFunction"
#   principal     = "apigateway.amazonaws.com"
#   source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/POST/"
#   # source_arn = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.api.id}/*/${aws_api_gateway_method.post_method.http_method}${aws_api_gateway_resource.resource.path}"

#   depends_on = [aws_api_gateway_rest_api.api]
# }



# # module "aws_dynamodb_table" {
# #   source = "git::git@github.com:Rockwell-Automation-Inc/terraform-aws-dynamodb-module.git?ref=v0.0.4"

# #   dynamodb_table_name                    = "test-token-validation-table"
# #   hash_key                               = "pk"
# #   range_key                              = "sk"
# #   read_capacity                          = 1
# #   write_capacity                         = 1
# #   auto_scaling_enabled                   = true
# #   auto_scaling_read_min_capacity         = 1
# #   auto_scaling_read_max_capacity         = 10
# #   auto_scaling_write_min_capacity        = 1
# #   auto_scaling_write_max_capacity        = 10
# #   aws_appautoscaling_policy_target_value = 70
# #   deletion_protection_enabled            = false
# #   ttl_attribute_name                     = "TimeToExist"
# #   ttl_enabled                            = true
# #   point_in_time_recovery_enabled         = false

# #   attributes = [
# #     {
# #       name = "pk"
# #       type = "S"
# #     },
# #     {
# #       name = "sk"
# #       type = "S"
# #     }
# #   ]
# #   # Tags.
# #   tags = var.tags
# # }


# output "invoke_arn" {
#   value       = module.aws_lambda_function.invoke_arn
#   description = "description"
# }

# output execution_arn {
#   value       = aws_api_gateway_rest_api.api.execution_arn
#   description = "description"

# }



