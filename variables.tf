/*
  Define Global variable
  example: Profile, Region, Terraform, Environment ..
*/
variable "profile" {
  description = "aws login profile"
  default     = ""
}

variable "region" {
  description = "aws region"
  default     = ""
}

variable "env" {
  description = "terraform workspace environment."
  default     = ""
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = "map"
  default     = {}
}

/*
  Define Resources variable
  example: VPC, EC2 ..
*/

variable "vpc_hub_cidr" {
  description = "VPC Hub CIDR Range"
  type        = "string"
  default     = ""
}

variable "vpc_azs" {
  description = "VPC Availability zone"
  type        = "list"
  default     = []
}

variable "vpc_private_subnets" {
  description = "VPC Private subnet CIDR"
  type        = "list"
  default     = []
}

variable "vpc_public_subnets" {
  description = "VPC Public subnet CIDR"
  type        = "list"
  default     = []
}

variable "vpc_ntp_servers" {
  description = "VPC DHCP NTP Servers"
  type        = "list"
  default     = []
}

/*
  Define Project variable
  example: name, owner, Tags..
*/
variable "web_name" {
  description = "A string of project name for web."
}

variable "web_asg_min_size" {
  description = "A string of autoscaling instance min size for web"
}

variable "web_asg_max_size" {
  description = "A string of autoscaling instance max size for web"
}

variable "web_asg_desired_capacity" {
  description = "A string of autoscaling instance desired capacity size for web"
}

variable "web_asg_health_check_type" {
  description = "A string of autoscaling health check type for web"
}

variable "web_instance_type" {
  description = "A string of instance type for web"
}

variable "web_alb_target_groups_defaults" {
  description = "A map of target groups default rule for web"
  type        = "map"
  default     = {}
}

variable "web_tags" {
  description = "A map of project tags for web"
  type        = "map"
  default     = {}
}
