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

resource "aws_launch_template" "template" {
  name_prefix   = "centos-test-"
  image_id      = var.ami_id
  instance_type = var.instance_type

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
