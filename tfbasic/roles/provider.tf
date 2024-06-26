
provider "aws" {
  region = local.aws_region
}

provider "aws" {
  alias  = "europe"
  region = local.aws_eu_region
}

provider "aws" {
  alias  = "ap"
  region = local.aws_ap_region
}