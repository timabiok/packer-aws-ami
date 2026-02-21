terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    key = "packer-aws-ami/servicenow/tests/terraform.tfstate"
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
  description = "AMI ID of the ServiceNow image to test"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID for the autoscaling group"
}

variable "iam_instance_profile" {
  type    = string
  default = "INSTANCESNOW"
}

resource "aws_launch_template" "template" {
  name_prefix   = "servicenow-test-"
  image_id      = var.ami_id
  instance_type = var.instance_type

  iam_instance_profile {
    name = var.iam_instance_profile
  }

  user_data = filebase64("${path.module}/userdata.sh")

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "servicenow-test"
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name = "servicenow-test"
    }
  }
}

resource "aws_autoscaling_group" "autoscale" {
  name                 = "servicenow-test-asg"
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
