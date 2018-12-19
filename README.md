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

[x] Versioning：Keep all versions of an object in the same bucket.
[x] Object lock：Permanently allow objects in this bucket to be locked.

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
```
module "vpc" {
  source  = "104corp/vpc/aws"
  version = "1.1.0"

  name            = "hub-workshop"
  cidr            = "10.0.0.0/16"
  azs             = ["ap-northeast-1a", "ap-northeast-1c"]
  public_subnets  = ["10.0.128.0/20", "10.0.32.0/19"]
  private_subnets = ["10.0.0.0/19", "10.0.144.0/20"]

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


**Step.6 測試 vpc resouce 建立**

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


















