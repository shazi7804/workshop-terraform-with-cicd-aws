data "aws_ami" "web_template_ami" {
  most_recent      = true
  #executable_users = ["self"]

  filter {
    name   = "name"
    values = ["*CURRENT-667cd56b-fd1b-45f3-8604-1fadab38134d-ami-042dbd40e23385f3f.4"]
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
  image_id              = "${data.aws_ami.web_template_ami.image_id}"
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
