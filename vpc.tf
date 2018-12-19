module "vpc" {
  source  = "104corp/vpc/aws"
  version = "1.1.0"

  name            = "hub-${var.env}"
  cidr            = "${var.vpc_hub_cidr}"
  azs             = ["${var.vpc_azs}"]
  public_subnets  = ["${var.vpc_public_subnets}"]
  private_subnets = ["${var.vpc_private_subnets}"]

  # endpoint
  enable_s3_endpoint       = true
  enable_dynamodb_endpoint = true

  tags = "${var.tags}"
}
