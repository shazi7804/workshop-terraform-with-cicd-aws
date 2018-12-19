# Global
profile = "104aws"
region = "ap-northeast-1"
env = "workshop"

tags = {
  Terraform   = "true"
  Version     = "v1.0.0"
  Environment = "workshop"
  Account     = "104aws"
}

# VPC Resource
vpc_hub_cidr        = "10.0.128.0/21"
vpc_azs             = ["ap-northeast-1a", "ap-northeast-1c"]
vpc_private_subnets = ["10.0.129.0/24", "10.0.130.0/24"]
vpc_public_subnets  = ["10.0.128.0/26", "10.0.128.64/26"]
vpc_ntp_servers     = ["169.254.169.123"]

web_name                       = "workshop-web"
web_instance_type              = "t2.nano"
web_asg_min_size               = 1
web_asg_max_size               = 2
web_asg_desired_capacity       = 1
web_asg_health_check_type      = "ELB"
web_alb_target_groups_defaults = {
  "cookie_duration"                  = 86400
  "deregistration_delay"             = 60
  "health_check_interval"            = 5
  "health_check_healthy_threshold"   = 2
  "health_check_path"                = "/"
  "health_check_port"                = "traffic-port"
  "health_check_timeout"             = 4
  "health_check_unhealthy_threshold" = 2
  "health_check_matcher"             = "200"
  "stickiness_enabled"               = false
  "target_type"                      = "instance"
}
