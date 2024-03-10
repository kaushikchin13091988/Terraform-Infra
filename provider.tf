terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 4.65.0"
        }
    }

    backend "s3" {
        bucket = "terraform-state-files-20231101"
        key = "terraform.tfstate"
    }
}

provider "aws" {}