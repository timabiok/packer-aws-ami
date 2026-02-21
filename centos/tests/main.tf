terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    key = "packer-aws-ami/centos/tests/terraform.tfstate"
  }
}

provider "aws" {
  region = var.region
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "ami_id" {
  type        = string
  description = "AMI ID of the CentOS base image to test"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "key_name" {
  type        = string
  description = "EC2 key pair name"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID for the launch template"
}

variable "security_group_ids" {
  type        = list(string)
  description = "Security group IDs for the network interface"
}

variable "iam_instance_profile" {
  type    = string
  default = "INSTANCESNOW"
}

resource "aws_launch_template" "template" {
  name_prefix   = "centos-test-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = var.security_group_ids
    subnet_id                   = var.subnet_id
  }

  iam_instance_profile {
    name = var.iam_instance_profile
  }

  user_data = filebase64("${path.module}/userdata.sh")

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "centos-test"
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name = "centos-test"
    }
  }
}

resource "aws_autoscaling_group" "autoscale" {
  name                 = "centos-test-asg"
  desired_capacity     = 1
  max_size             = 1
  min_size             = 1
  health_check_type    = "EC2"
  termination_policies = ["OldestInstance"]
  vpc_zone_identifier  = [var.subnet_id]

  launch_template {
    id      = aws_launch_template.template.id
    version = "$Latest"
  }
}
