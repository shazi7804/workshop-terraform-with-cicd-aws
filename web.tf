data "aws_ami" "workshop" {
  most_recent = true

  filter {
    name   = "state"
    values = ["available"]
  }

  filter {
    name   = "name"
    values = ["workshop-ami-*"]
  }
}

module "web" {
  source  = "104corp/web/aws"
  version = "0.0.12"

  name                  = "${var.web_name}"
  env                   = "${var.env}"
  vpc_id                = "${module.vpc.vpc_id}"
  asg_min_size          = "${var.web_asg_min_size}"
  asg_max_size          = "${var.web_asg_max_size}"
  asg_desired_capacity  = "${var.web_asg_desired_capacity}"
  asg_health_check_type = "${var.web_asg_health_check_type}"
  instance_type         = "${var.web_instance_type}"
  image_id              = "${data.aws_ami.workshop.image_id}"
  ec2_subnet_ids        = "${module.vpc.private_subnets}"
  alb_subnet_ids        = "${module.vpc.public_subnets}"
  key_name              = ""

  # with CI / CD setting
  travisci_enable   = true
  codedeploy_enable = true
  web_ingress_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      source_security_group_id = "${module.web.alb_sg_id}"
    },
  ]
  web_number_of_ingress_source_security_group_id = 1
  alb_target_groups_defaults                     = "${var.web_alb_target_groups_defaults}"

  tags                        = "${merge(var.tags, var.web_tags)}"
}
