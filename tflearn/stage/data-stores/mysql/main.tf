provider "aws" {
  region = "us-east-2"
}

resource "aws_db_instance" "example" {
  identifier_prefix   = "johadb"
  engine              = "mysql"
  allocated_storage   = 10
  instance_class      = "db.t2.micro"
  skip_final_snapshot = true
  db_name             = "joha_db"  # How should we set the username and password?
  username = var.db_username
  password = var.db_password
}

terraform {
  backend "s3" {
    # Replace this with your bucket name!
    bucket         = "terraform-state-joha"
    key            = "stage/data-stores/mysql/terraform.tfstate"
    region         = "us-east-2"

    # Replace this with your DynamoDB table name!
    dynamodb_table = "terraform-state-joha-locks"
    encrypt        = true
  }
}