
variable "tags" {
  type = map(string)
}

variable "amis_region" {
  type    = list(string)
  default = ["us-east-1", "eu-west-1", "ap-northeast-1"]

}