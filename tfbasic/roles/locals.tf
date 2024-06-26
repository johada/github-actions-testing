
locals {
  tags = merge({
    "ApplicationName" = "Example",
    "Capability"      = "Example"
  })
  aws_region    = "us-east-1"
  aws_eu_region = "eu-west-1"
  aws_ap_region = "ap-northeast-1"
}
