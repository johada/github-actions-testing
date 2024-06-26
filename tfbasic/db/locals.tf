locals {
  type-by-tier = {
    "Large:Non-Graphics" = {
      "c5.2xlarge" = [
        "ap-northeast-1",
        "us-east-1",
        "eu-west-1"
      ]
    },
    "Small:Graphics" = {
      "g4ad.xlarge" = [
        "ap-northeast-1",
        "us-east-1",
        "eu-west-1"
      ]
    },
    "Medium:Graphics" = {
      "g4ad.2xlarge" = [
        "ap-northeast-1",
        "us-east-1",
        "eu-west-1"
      ]
    },
    "Large:Graphics" = {
      "g4ad.4xlarge" = [
        "ap-northeast-1",
        "us-east-1",
        "eu-west-1"
      ]
    },
    "Small:Non-Graphics" = {
      "c5.large" = [
        "ap-northeast-1",
        "us-east-1",
        "eu-west-1"
      ]
    },
    "Medium:Non-Graphics" = {
      "c5.xlarge" = [
        "ap-northeast-1",
        "us-east-1",
        "eu-west-1"
      ]
    }
  }

  flattened_types = flatten([
    for type, tiers in local.type-by-tier : [
      for tier, regions in tiers : [
        for region in regions : {
          type   = type
          tier   = tier
          region = region
        }
      ]
    ]
  ])
}