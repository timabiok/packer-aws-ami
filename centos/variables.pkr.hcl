variable "region" {
  type        = string
  description = "AWS region to build the AMI in"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type for the Packer builder"
}

variable "iam_instance_profile" {
  type        = string
  description = "IAM instance profile to attach to the builder instance"
}

variable "source_ami_owners" {
  type        = list(string)
  description = "Owner account IDs for the source AMI filter"
}

variable "ssh_username" {
  type        = string
  description = "SSH username for provisioner connection"
}

variable "source_ami_name" {
  type        = string
  description = "Name filter pattern for the source AMI"
}

variable "subnet_filter_name" {
  type        = string
  description = "Tag:Name filter pattern for subnet selection"
}
