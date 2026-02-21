variable "region" {
  type        = string
  description = "AWS region"
}

variable "ami_id" {
  type        = string
  description = "AMI ID of the CentOS base image to test"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type for the test instance"
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
  type        = string
  description = "IAM instance profile to attach to test instances"
}
