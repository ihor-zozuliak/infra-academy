terraform {
  backend "s3" {
    bucket         = "remote-backend-s3-85687546754612322"
    key            = "infra/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "remote-backend"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.34.0"
    }
    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.1.0"
    }
  }
}
