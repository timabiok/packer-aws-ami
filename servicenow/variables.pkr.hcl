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

variable "subnet_id" {
  type        = string
  default     = null
  description = "Subnet ID for build instance. When set, overrides subnet_filter. Use network Terraform output build_subnet_id when using the repo's network layer."
}

variable "subnet_filter_name" {
  type        = string
  default     = null
  description = "Tag:Name filter pattern for subnet selection (used only when subnet_id is not set)"
}

variable "security_group_ids" {
  type        = list(string)
  default     = []
  description = "Security group IDs for the build instance. Use network output build_security_group_ids when using the repo's network layer."
}

variable "root_volume_size" {
  type        = number
  description = "Root EBS volume size in GB"
}

variable "bucket" {
  type        = string
  description = "S3 bucket containing the ServiceNow installation archive"
}

variable "key" {
  type        = string
  description = "S3 object key for the ServiceNow installation zip"
}

variable "useful_ports" {
  type        = list(number)
  description = "ServiceNow node ports (UI and worker)"
}

variable "java_installer" {
  type        = string
  description = "Java package name for installation"
}
