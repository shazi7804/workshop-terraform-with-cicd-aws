# Terraform with CI / CD on AWS

## Introduction

infrastructure as code 該怎麼入手 ? 這個 WorkShop 體驗從零到高手的歷程，透過 module 實現省錢又 Autoscaling 架構，原來 infrastructure as code 也能這麼簡單。

## Overview

![overview](./img/overview.png)

### Backend

- Backend store：S3
- State locking：DynamoDB

## LAB

**Step.1 建立給 Terraform 使用的 IAM User (AdministratorAccess)**

Terraform 是唯一該帳號的資源建立者，所以權限給予 AdministratorAccess，如果有確定該帳號不必要的服務，也可以從 Policy 控制 Terraform 的 IAM User 權限。

將 AWS Key export 環境變數給 Terraform 使用。

```
$ export AWS_ACCESS_KEY_ID=AKIA.....
$ export AWS_SECRET_ACCESS_KEY=GoO4f....
```


**Step.2 建立 S3 和 DynamoDB 作為 State backend**

- S3 bucket：workshop-terraform-2e21m1dpq04fwfp (Without ACL and Policy)

- [x] Versioning：Keep all versions of an object in the same bucket.
- [x] Object lock：Permanently allow objects in this bucket to be locked.

- Dynamodb
  - Table Name：terraform-state-locking
  - Primary partition key：LockID (String)


**Step.3 建立 Github repository，clone 到本機**

```
# example
$ git clone https://github.com/shazi7804/workshop-terraform-with-cicd-aws
```


**Step.4 建立 terraform 主要設定檔 main.tf，加入 backend 和 provider。**

- main.tf
```
terraform {
  backend "s3" {
    bucket         = "workshop-terraform-2e21m1dpq04fwfp"
    dynamodb_table = "terraform-state-locking"
    key            = "main/terraform.tfstate"
    region         = "ap-northeast-1"
  }
}

provider "aws" {
  region = "ap-northeast-1"
}
```

測試初始化 backend

```
$ terraform init

Initializing the backend...
Initializing provider plugins...
...
Terraform has been successfully initialized!
```


**Step.5 使用 [104corp/vpc](https://registry.terraform.io/modules/104corp/vpc/aws/) 模組快速建立 VPC。**

- vpc.tf

```terraform
module "vpc" {
  source  = "104corp/vpc/aws"
  version = "1.1.0"

  name            = "hub-workshop"
  cidr            = "10.0.0.0/16"
  azs             = ["ap-northeast-1a", "ap-northeast-1c"]
  public_subnets  = ["10.0.128.0/20", "10.0.144.0/20"]
  private_subnets = ["10.0.0.0/19", "10.0.32.0/19"]

  # endpoint
  enable_s3_endpoint       = true
  enable_dynamodb_endpoint = true

  tags = {
    Terraform   = "true"
    Environment = "workshop"
    Account     = "104aws"
  }
}
```


**Step.6 測試 VPC resouce 建立**

初始化 vpc 模組

```
$ terraform init
```

使用 terraform plan 查看變更項目

```
$ terraform plan


Terraform will perform the following actions:

  + module.vpc.aws_internet_gateway.this
  + module.vpc.aws_route.public_internet_gateway
  + module.vpc.aws_route_table.private[0]
  + module.vpc.aws_route_table.private[1]
  + module.vpc.aws_route_table.public
  + module.vpc.aws_route_table_association.private[0]
  + module.vpc.aws_route_table_association.private[1]
  + module.vpc.aws_route_table_association.public[0]
  + module.vpc.aws_route_table_association.public[1]
  + module.vpc.aws_subnet.private[0]
  + module.vpc.aws_subnet.private[1]
  + module.vpc.aws_subnet.public[0]
  + module.vpc.aws_subnet.public[1]
  + module.vpc.aws_vpc.this
  + module.vpc.aws_vpc_endpoint.dynamodb
  + module.vpc.aws_vpc_endpoint.s3
  + module.vpc.aws_vpc_endpoint_route_table_association.private_dynamodb
  + module.vpc.aws_vpc_endpoint_route_table_association.private_s3
  + module.vpc.aws_vpc_endpoint_route_table_association.public_dynamodb
  + module.vpc.aws_vpc_endpoint_route_table_association.public_s3

Plan: 20 to add, 0 to change, 0 to destroy.
```

使用 terraform apply 確認佈署

```
$ terraform apply
```

檢查 VPC 建立成功。


**Step.7 參數抽離**

- vpc.tf

```terraform
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
```

- variable.tf 宣告 variable 資料型態、預設值。

```terraform
/*
  Define Global variable
  example: Profile, Region, Terraform, Environment ..
*/
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
```

- main.auto.tfvars 儲存真實數值

```terraform
# Global
region = "ap-northeast-1"
env = "workshop"

tags = {
  Terraform   = "true"
  Environment = "workshop"
  Account     = "104aws"
}

# VPC Resource
vpc_hub_cidr        = "10.0.0.0/16"
vpc_azs             = ["ap-northeast-1a", "ap-northeast-1c"]
vpc_public_subnets = ["10.0.128.0/20", "10.0.144.0/20"]
vpc_private_subnets  = ["10.0.0.0/19", "10.0.32.0/19"]
```

測試 terraform plan 沒有 resource 被異動

```
$ terraform plan

Plan: 0 to add, 0 to change, 0 to destroy.
```

**Step.8 使用 [104corp/web](https://registry.terraform.io/modules/104corp/web/aws/) 模組快速建立 EC2 Autoscaling。**

- web.tf

```
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
```

- 把 web 變數宣告至 variable.tf

```
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
```

- 增加 web 參數至 main.auto.tfvars

```terraform
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
```

Deploy 並驗證 Autoscaling

```
$ terraform init
$ terraform plan
$ terraform apply
```


**Step.9 使用 Travis CI 進行 CI / CD**

- 加入 .travis.yml

```terraform
language: bash
cache:
  directories:
    - .terraform
env:
  global:
    - TFLINT_VER='v0.7.1'
    - TERRAFORM_VER='0.11.7'
before_install:
  # Install Terraform
  - "wget https://releases.hashicorp.com/terraform/0.11.7/terraform_${TERRAFORM_VER}_linux_amd64.zip"
  - "unzip terraform_${TERRAFORM_VER}_linux_amd64.zip && chmod +x terraform"
  # Install dependencies
  - "./terraform init"
  - "./terraform fmt"
script:
  # Test case
  - "./terraform plan"
  # terraform apply deploy
after_success:
  - "./terraform apply -auto-approve"
notifications:
  email: false
```

- 將 AWS_ACCESS_KEY_ID 和 AWS_SECRET_ACCESS_KEY 設定至 Travis CI 的 Environment。

- git push



**Step.10 使用 destroy 清場**

```terraform
$ terraform destroy
```


**Step.11 移除 backend**

- delete S3
- delete DynamoDB
