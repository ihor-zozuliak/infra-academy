terraform {
  required_version = "1.3.2"
  backend "s3" {
    bucket         = "remote-backend-s3-85687546754612322"
    key            = "global/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "remote-backend"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.34.0"
    }
  }
}
