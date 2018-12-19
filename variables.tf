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

