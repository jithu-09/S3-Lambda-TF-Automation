terraform {
  required_version = "1.6.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.32.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  
}

terraform {
    backend "s3" {
        bucket         = "tfbackend-j09"
        key            = "backend/tfstate"
        region         = "us-east-1"
        encrypt = true
    }
}