
resource "aws_iam_policy" "policy" {
  name        = "test_lambda_policy_for_appstream_file_detection-${var.region}"
  description = "A policy to allow lambda to write logs"
  policy      = data.aws_iam_policy_document.role_policy.json
}

resource "aws_iam_role_policy_attachment" "policy_attachment" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "test_lambda_role_for_appstream_file_detection-${var.region}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

module "aws_lambda_function" {

  source = "git::git@github.com:Rockwell-Automation-Inc/terraform-aws-lambda-function-module.git?ref=v0.0.10"

  lambda_function_file    = "${path.module}/lambda_function.py"
  lambda_function_name    = "test_appstream_files_detection-${var.region}"
  lambda_function_role    = aws_iam_role.iam_for_lambda.arn
  lambda_function_handler = "lambda_function.lambda_handler"
  lambda_function_runtime = "python3.11"

  # Tags.
  tags = var.tags

  tracing_config = {
    mode = "Active"
  }
}

resource "aws_s3_bucket_notification" "bucket_notification" {

  bucket = data.aws_s3_bucket.appstream_bucket.id

  lambda_function {
    lambda_function_arn = module.aws_lambda_function.function_arn
    events              = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
    filter_prefix       = "user/custom/"
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}

resource "aws_lambda_permission" "allow_bucket" {

  statement_id   = "AllowExecutionFromS3Bucket-${var.region}"
  action         = "lambda:InvokeFunction"
  function_name  = module.aws_lambda_function.function_name
  principal      = "s3.amazonaws.com"
  source_arn     = data.aws_s3_bucket.appstream_bucket.arn
  source_account = data.aws_caller_identity.current.account_id
}

module "aws_dynamodb_table" {
  source = "git::git@github.com:Rockwell-Automation-Inc/terraform-aws-dynamodb-module.git?ref=v0.0.4"

  dynamodb_table_name                    = "test_appstream_files_detection_table"
  hash_key                               = "pk"
  range_key                              = "sk"
  read_capacity                          = 1
  write_capacity                         = 1
  auto_scaling_enabled                   = true
  auto_scaling_read_min_capacity         = 1
  auto_scaling_read_max_capacity         = 10
  auto_scaling_write_min_capacity        = 1
  auto_scaling_write_max_capacity        = 10
  aws_appautoscaling_policy_target_value = 70
  deletion_protection_enabled            = false

  attributes = [
    {
      name = "pk"
      type = "S"
    },
    {
      name = "sk"
      type = "S"
    }
  ]
  # Tags.
  tags = var.tags
}
