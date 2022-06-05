terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  profile = "prod"
}

//Get aws instance details
data "aws_instance" "source_instance" {
  instance_id = var.source_instance_id
}

output "source_instance" {
  value       = "${data.aws_instance.source_instance}"
  description = "Source Instance Details"
}

resource "aws_ami_from_instance" "sourceami" {
  name               = "source-instance"
  source_instance_id = var.source_instance_id
}

resource "aws_instance" "newinstance" {
    ami           = aws_ami_from_instance.sourceami.id
    instance_type = data.aws_instance.source_instance.instance_type
    vpc_security_group_ids = data.aws_instance.source_instance.vpc_security_group_ids
    subnet_id = data.aws_instance.source_instance.subnet_id
    tags = {
        Name = "${data.aws_instance.source_instance.tags.Name}-cloned"
    }
}
