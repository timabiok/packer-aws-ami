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
  default     = null
  description = "Subnet ID for the launch template. When use_network_state is true, defaults to network output build_subnet_id; otherwise required."
}

variable "security_group_ids" {
  type        = list(string)
  default     = []
  description = "Security group IDs for the test instances. When use_network_state is true, defaults to network output build_security_group_ids."
}

variable "use_network_state" {
  type        = bool
  default     = false
  description = "When true, read subnet_id and security_group_ids from network Terraform state (requires terraform_state_bucket)."
}

variable "terraform_state_bucket" {
  type        = string
  default     = ""
  description = "S3 bucket for Terraform state (required when use_network_state is true)."
}

variable "network_state_key" {
  type        = string
  default     = "packer-aws-ami/network/terraform.tfstate"
  description = "S3 key for network state. Use packer-aws-ami/network-existing/terraform.tfstate when using existing IDs."
}

variable "iam_instance_profile" {
  type        = string
  description = "IAM instance profile to attach to test instances"
}
