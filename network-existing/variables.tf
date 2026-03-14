variable "region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region"
}

variable "existing_vpc_id" {
  type        = string
  description = "Existing VPC ID"
}

variable "existing_subnet_ids" {
  type        = list(string)
  description = "Existing subnet IDs for builds (e.g. public). First is used for Packer."
}

variable "existing_security_group_ids" {
  type        = list(string)
  default     = []
  description = "Existing security group IDs for build instances"
}
