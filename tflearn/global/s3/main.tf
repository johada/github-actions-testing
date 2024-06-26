provider "aws" {
  region = "us-east-2"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
    account_id = data.aws_caller_identity.current.account_id
    region = data.aws_region.current.name
}


resource "aws_s3_bucket" "test-policies-s3" {
  bucket = "testing-policies-harness"
 
  # Prevent accidental deletion of this S3 bucket
#   lifecycle {
#     prevent_destroy = true
#   }
}

resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.test-policies-s3.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.test-policies-s3.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.test-policies-s3.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# resource "aws_s3_bucket_policy" "cloud_cost_management_bucket_policy" {
#   bucket = aws_s3_bucket.test-policies-s3.id
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Id      = "Security_Policy"
#     Statement = [
#       {
#         Sid       = "AllowSSLRequestsOnly"
#         Effect    = "Deny"
#         Principal = "*"
#         Action    = "s3:*"
#         Resource = [
#           "arn:aws:s3:::${aws_s3_bucket.test-policies-s3.id}/*",
#           "arn:aws:s3:::${aws_s3_bucket.test-policies-s3.id}"
#         ]
#         Condition = {
#           Bool = {
#             "aws:SecureTransport" = "false"
#           }
#         }
#       },
#       {
#         Sid       = "PreventAccidentalDeletionOfBucket",
#         Effect    = "Deny",
#         Principal = "*",
#         Action    = "s3:DeleteBucket",
#         Resource  = "arn:aws:s3:::${aws_s3_bucket.test-policies-s3.id}"
#       },
#       {
#         Sid       = "AllowBillingReportsAccess",
#         Effect    = "Allow",
#         Principal = {
#           Service : "billingreports.amazonaws.com"
#         },
#         Action = [
#           "s3:GetBucketAcl",
#           "s3:GetBucketPolicy"
#         ],
#         Resource = [
#           "arn:aws:s3:::${aws_s3_bucket.test-policies-s3.id}/*",
#           "arn:aws:s3:::${aws_s3_bucket.test-policies-s3.id}"
#         ]
#         Condition = {
#           StringEquals = {
#             "aws:SourceArn" = "arn:aws:cur:${aws_s3_bucket.test-policies-s3.region}:${data.aws_caller_identity.current.account_id}:definition/*",
#             "aws:SourceAccount" = "${local.account_id}"
#           }
#         }
#       },
#       {
#         Sid       = "AllowBillingReportsPut",
#         Effect    = "Allow",
#         Principal = {
#           Service : "billingreports.amazonaws.com"
#         },
#         Action = [
#           "s3:PutObject"
#         ],
#         Resource = [
#           "arn:aws:s3:::${aws_s3_bucket.test-policies-s3.id}/*",
#           "arn:aws:s3:::${aws_s3_bucket.test-policies-s3.id}"
#         ]
#         Condition = {
#           StringEquals = {
#             "aws:SourceArn" = "arn:aws:cur:${aws_s3_bucket.test-policies-s3.region}:${data.aws_caller_identity.current.account_id}:definition/*",
#             "aws:SourceAccount" = data.aws_caller_identity.current.account_id
#           }
#         }
#       }
#     ]
#   })
# }

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-state-joha-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

terraform {
  backend "s3" {
    # Replace this with your bucket name!
    bucket         = "terraform-state-joha"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-2"

    # Replace this with your DynamoDB table name!
    dynamodb_table = "terraform-state-joha-locks"
    encrypt        = true
  }
}
