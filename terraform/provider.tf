terraform {
  required_providers {
    aws={
        source="hashicorp/aws"
        version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">=2.7.1"
    }

    local = {
      source  = "hashicorp/local"
      version = "~> 2.1.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.1.0"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "~> 2.2.0"
    }
  }
   backend "s3"{
    bucket = "divya-tf-state-bucket"
    key = "tf-infra/terraform.tfstate"
    region = "us-west-1"
    dynamodb_table = "state-lock-bcvket"
    encrypt = true
   }

}
# provider "aws" {
#   region = "us-west-1"
# }