module "aws_dynamodb_table" {
  source = "git::git@github.com:Rockwell-Automation-Inc/terraform-aws-dynamodb-module.git?ref=v0.0.5"

  dynamodb_table_name                    = "test-twin-studio-ec2-instance-type-by-tier"
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
  point_in_time_recovery_enabled         = true

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

resource "aws_dynamodb_table_item" "example" {
  for_each = { for i, value in local.flattened_types : "${value.type}-${value.tier}-${value.region}" => value }

  table_name = module.aws_dynamodb_table.id
  hash_key   = module.aws_dynamodb_table.hash_key
  range_key  = module.aws_dynamodb_table.range_key

  item = jsonencode({
    "${module.aws_dynamodb_table.hash_key}"   = {"S": each.value.type},
    "${module.aws_dynamodb_table.range_key}"  = {"S": each.value.region},
    "type" = {"S": each.value.tier}
  })
}