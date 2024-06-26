output "s3_bucket_arn" {
  value       = aws_s3_bucket.test-policies-s3.arn
  description = "The ARN of the S3 bucket"
}

output "s3_bucket_region" {
  value       = local.region
  description = "The region of the S3 bucket"
}

output "account_id" {
  value = local.account_id
}
# output "dynamodb_table_name" {
#   value       = aws_dynamodb_table.terraform_locks.name
#   description = "The name of the DynamoDB table"
# }