terraform {
  backend "s3" {
    bucket         = "workshop-terraform-2e21m1dpq04fwfp"
    dynamodb_table = "terraform-state-locking"
    key            = "main/terraform.tfstate"
    region         = "ap-northeast-1"
  }
}

provider "aws" {
  region = "${var.region}"
}
