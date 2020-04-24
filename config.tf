resource "aws_s3_bucket" "terraform_state_storage" {
  acl    = "private"
  bucket = "possoir-terraform-states"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

provider "aws" {
  region  = "eu-west-1"
  profile = "possoir"
}

terraform {
  backend "s3" {
    bucket  = "possoir-terraform-states"
    key     = "production.tfstate"
    region  = "eu-west-1"
    profile = "possoir"
  }
}
