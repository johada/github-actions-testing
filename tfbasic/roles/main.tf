data "aws_caller_identity" "current" {}

data "aws_iam_user" "fthub_access_keys_user" {
  user_name = "fthub_access_keys_user_sandbox"
}
data "aws_iam_user" "fthub_terraform" {
  user_name = "fthub_terraform"
}
data "aws_iam_role" "twin_studio_task_role" {
  name = "twin-studio-task-role"
}

data "aws_iam_user" "twin_studio_developers_user" {
  for_each  = var.environment == "sandbox" ? toset(["sandbox"]) : toset([])
  user_name = "TS-WS-ADMIN"
}

output "fthub_access_keys_user" {
  value = data.aws_iam_user.fthub_access_keys_user.id
}

output "fthub_terraform" {
  value = data.aws_iam_user.fthub_terraform.id
}

output "twin_studio_task_role" {
  value = data.aws_iam_role.twin_studio_task_role.unique_id
}


output "twin_studio_developers_user" {
  value = try(data.aws_iam_user.twin_studio_developers_user["sandbox"].id, null)
}


data "aws_iam_policy_document" "twin_studio_workspaces_s3" {
  statement {
    sid    = "AllowOnlySpecificUsers"
    effect = "Deny"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = ["s3:PutObject",
      "s3:PutBucketCORS",
      "s3:PutBucketOwnershipControls",
      "s3:PutBucketPolicy",
      "s3:DeleteBucket",
      "s3:DeleteObject",
      "s3:GetBucketPolicy"
    ]
    resources = [
      "arn:aws:s3:::*"
    ]

    condition {
      test     = "StringNotLike"
      variable = "aws:userId"
      values = [
        "${data.aws_iam_user.fthub_access_keys_user.id}",
        "${data.aws_iam_user.fthub_terraform.id}",
        try(data.aws_iam_user.twin_studio_developers_user["sandbox"].id, "")
      ]
    }
  }
}






















# data "aws_iam_policy_document" "workstations_assume_role" {
#   statement {
#     actions = ["sts:AssumeRole"]

#     principals {
#       type        = "Service"
#       identifiers = ["ec2.amazonaws.com", "ssm.amazonaws.com"]  
#     }
#   }
# }

# data "aws_iam_policy_document" "workstations_policy_document" {
#     statement {
#         effect = "Allow"
#         actions = [
#             "s3:Get*",
#             "s3:List*",
#             "s3:Describe*",
#             "s3:PutObject",
#             "s3:GetObject",
#             "s3:ListBucket",
#             "s3:DeleteObject",
#             "s3-object-lambda:Get*",
#             "s3-object-lambda:List*",
#             "ssm:DescribeAssociation",
#             "ssm:GetDeployablePatchSnapshotForInstance",
#             "ssm:GetDocument",
#             "ssm:DescribeDocument",
#             "ssm:GetManifest",
#             "ssm:GetParameter",
#             "ssm:GetParameters",
#             "ssm:ListAssociations",
#             "ssm:ListInstanceAssociations",
#             "ssm:PutInventory",         
#             "ssm:PutComplianceItems",
#             "ssm:PutConfigurePackageResult",
#             "ssm:UpdateAssociationStatus",
#             "ssm:UpdateInstanceAssociationStatus",
#             "ssm:UpdateInstanceInformation",             
#             "ssm:CreateAssociation",
#             "ssm:DeleteAssociation",
#             "ssm:DescribeAssociation",
#             "ssmmessages:CreateControlChannel",
#             "ssmmessages:CreateDataChannel",
#             "ssmmessages:OpenControlChannel",
#             "ssmmessages:OpenDataChannel",
#             "ec2messages:AcknowledgeMessage",
#             "ec2messages:DeleteMessage",
#             "ec2messages:FailMessage",
#             "ec2messages:GetEndpoint",
#             "ec2messages:GetMessages",
#             "ec2messages:SendReply",
#             "tag:GetResources",
#             "ssm:DescribePatchBaselines"
#         ]
#         resources = ["*"]
#     }
#     statement {
#         effect = "Allow"
#         actions = [
#             "ssm:DescribeEffectivePatchesForPatchBaseline",
#             "ssm:GetPatchBaseline"
#         ]
#         resources = [
#             "arn:aws:ssm:*:*:patchbaseline/*"
#         ]
#     }
#     statement {
#         effect = "Allow"
#         actions = [
#             "s3:GetObject"
#         ]
#         resources = [
#            "arn:aws:s3:::dcv-license.*"
#         ]
#     }
#     statement {
#         effect = "Allow"
#         actions = [
#             "cloudformation:DescribeStackResource",
#             "cloudformation:SignalResource"
#         ]
#         resources = [
#             "arn:aws:cloudformation:us-east-1:${data.aws_caller_identity.current.account_id}:stack/*"
#         ]
#     }
# }

# resource "aws_iam_policy" "workstations_policy" {
#   name   = "workstations_role_policy"
#   policy = data.aws_iam_policy_document.workstations_policy_document.json
# }

# resource "aws_iam_role" "workstations_role" {
#   name               = "workstations-role"
#   assume_role_policy = data.aws_iam_policy_document.workstations_assume_role.json
# }

# resource "aws_iam_role_policy_attachment" "workstations_policy_attachment" {
#   role       = aws_iam_role.workstations_role.name
#   policy_arn = aws_iam_policy.workstations_policy.arn
# }