
# module "token_validation_us_east_1" {
#   source = "./workspaces"
#   region = local.aws_region
#   tags   = merge(local.tags, { Capability = "Example", ApplicationName = "Example" })

#   providers = {
#     aws = aws
#   }
# }
# module "token_validation_europe" {
#   source = "./workspaces"
#   region = local.aws_eu_region
#   tags   = merge(local.tags, { Capability = "Example", ApplicationName = "Example" })

#   providers = {
#     aws = aws.europe
#   }
# }

# module "token_validation_ap" {
#   source = "./workspaces"
#   region = local.aws_ap_region
#   tags   = merge(local.tags, { Capability = "Example", ApplicationName = "Example" })

#   providers = {
#     aws = aws.ap
#   }
# }



# module "appstream_files_detection_us_east_1" {
#   source = "./appstream_files_detection"
#   region = local.aws_region
#   tags   = merge(local.tags, { Capability = "AppStream", ApplicationName = "fthub_digital_engineering" })

#   providers = {
#     aws = aws
#   }
# }

# module "appstream_files_detection_eu_west_1" {
#   source = "./appstream_files_detection"
#   region = local.aws_eu_region
#   tags   = merge(local.tags, { Capability = "AppStream", ApplicationName = "fthub_digital_engineering" })

#   providers = {
#     aws = aws.europe
#   }
# }

# module "appstream_files_detection_ap_northeast_1" {
#   source = "./appstream_files_detection"
#   region = local.aws_ap_region
#   tags   = merge(local.tags, { Capability = "AppStream", ApplicationName = "fthub_digital_engineering" })

#   providers = {
#     aws = aws.ap
#   }
# }

module "dynamodb_table" {
  source = "./db"
  tags   = merge(local.tags, { Capability = "AppStream", ApplicationName = "fthub_digital_engineering" })
}




