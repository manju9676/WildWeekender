terraform {
  backend "s3" {
  bucket = "wildweekender-terraform-state"
  key    = "terraform.tfstate"
  region = "us-east-1"
    }
}

