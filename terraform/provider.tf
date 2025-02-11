terraform {
  required_providers {
    aws={
        source="hashicorp/aws"
        version = "~> 5.0"
    }
  }
#    backend "s3"{
#     bucket = "divya-tf-state-bucket"
#     key = "tf-infra/terraform.tfstate"
#     region = "us-west-1"
#     dynamodb_table = "state-lock-bcvket"
#     encrypt = true
#   }
}
provider "aws" {
  region = "us-west-1"
}