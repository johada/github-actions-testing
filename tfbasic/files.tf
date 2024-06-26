# data "aws_caller_identity" "current" {}

# provider "aws" {
#   region = local.aws_region
# }

# provider "aws" {
#   alias  = "europe"
#   region = local.aws_eu_region
# }

# provider "aws" {
#   alias  = "ap"
#   region = local.aws_ap_region
# }


# //variable that will be used to know various regions where the lambda function will be deployed
# variable "bucket_regions" {
#   type        = list(string)
#   default     = [
#     "us-west-1",
#     "us-east-1",
#     "ap-northeast-1"]
#   description = "description"
# }

# data "aws_iam_policy_document" "assume_role" {
#   statement {
#     effect = "Allow"

#     principals {
#       type        = "Service"
#       identifiers = ["lambda.amazonaws.com"]
#     }

#     actions = ["sts:AssumeRole"]
#   }
# }

# data "aws_iam_policy_document" "role_policy" {
#   statement {
#     effect = "Allow"

#     actions = [
#         "logs:CreateLogGroup",
#         "logs:CreateLogStream",
#         "logs:PutLogEvents"]

#     resources = ["arn:aws:logs:*:*:*"]
#   }
# }

# resource "aws_iam_policy" "policy" {
#   name        = "lambda_policy"
#   description = "A policy to allow lambda to write logs"
#   policy      = data.aws_iam_policy_document.role_policy.json
# }

# resource "aws_iam_role_policy_attachment" "policy_attachment" {
#   role       = aws_iam_role.iam_for_lambda.name
#   policy_arn = aws_iam_policy.policy.arn
# }

# resource "aws_iam_role" "iam_for_lambda" {
#   name = "lambda_role_for_file_detection"
#   assume_role_policy = data.aws_iam_policy_document.assume_role.json
# }

# data "archive_file" "python_lambda_package" {  
#   type = "zip"  
#   source_file = "${path.module}/lambda_function.py" 
#   output_path = "lambda_function.zip"
# }

# resource "aws_lambda_function" "test_lambda" {

#   for_each = toset(var.bucket_regions)

#   filename         = "lambda_function.zip"
#   function_name    = "lambda_function_file_detection-${each.value}"
#   role             = aws_iam_role.iam_for_lambda.arn
#   handler          = "lambda_function.lambda_handler"
#   source_code_hash = data.archive_file.python_lambda_package.output_base64sha256
#   runtime = "python3.9"
# }

# resource "aws_s3_bucket" "bucket" {
#   for_each = toset(var.bucket_regions)

#   bucket   = "appstream-36fb080bb8-${each.value}-${data.aws_caller_identity.current.account_id}"
# }

# resource "aws_s3_bucket_notification" "bucket_notification" {

#   for_each = aws_s3_bucket.bucket
#   bucket = aws_s3_bucket.bucket[each.key].id

#   lambda_function {
#     lambda_function_arn = aws_lambda_function.test_lambda[each.key].arn
#     events              = ["s3:ObjectCreated:*","s3:ObjectRemoved:*"]
#     filter_prefix       = "user/custom/"
#   }

#   depends_on = [aws_lambda_permission.allow_bucket]
# }

# resource "aws_lambda_permission" "allow_bucket" {
#   for_each = aws_s3_bucket.bucket

#   statement_id  = "AllowExecutionFromS3Bucket-${each.key}"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.test_lambda[each.key].arn
#   principal     = "s3.amazonaws.com"
#   source_arn    = aws_s3_bucket.bucket[each.key].arn
# }

# resource "aws_dynamodb_table" "basic-dynamodb-table" {
#   name           = "fileDetection-2525"
#   billing_mode   = "PROVISIONED"
#   read_capacity  = 20
#   write_capacity = 20
#   hash_key       = "pk"
#   range_key      = "sk"

#   attribute {
#     name = "pk"
#     type = "S"
#   }

#   attribute {
#     name = "sk"
#     type = "S"
#   }

#   ttl {
#     attribute_name = "TimeToExist"
#     enabled        = false
#   }

#   tags = {
#     Name        = "testing-file-detection"
#     Environment = "sandbox"
#   }
# }

