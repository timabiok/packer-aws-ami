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

# Optional: read subnet and SG from network layer state
data "terraform_remote_state" "network" {
  count   = var.use_network_state ? 1 : 0
  backend = "s3"
  config = {
    bucket = var.terraform_state_bucket
    key    = var.network_state_key
    region = var.region
  }
}

locals {
  subnet_id          = var.use_network_state ? (length(data.terraform_remote_state.network) > 0 ? data.terraform_remote_state.network[0].outputs.build_subnet_id : var.subnet_id) : var.subnet_id
  security_group_ids = var.use_network_state ? (length(data.terraform_remote_state.network) > 0 ? data.terraform_remote_state.network[0].outputs.build_security_group_ids : var.security_group_ids) : var.security_group_ids
}

resource "aws_launch_template" "template" {
  name_prefix   = "servicenow-test-"
  image_id      = var.ami_id
  instance_type = var.instance_type

  iam_instance_profile {
    name = var.iam_instance_profile
  }

  vpc_security_group_ids = length(local.security_group_ids) > 0 ? local.security_group_ids : null

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
  vpc_zone_identifier  = [local.subnet_id]

  launch_template {
    id      = aws_launch_template.template.id
    version = "$Latest"
  }
}
