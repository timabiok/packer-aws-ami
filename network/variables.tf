#-----------------------------------------------------------------------------
# VPC module inputs (https://github.com/timabiok/terraform-aws-vpc)
# For using existing IDs instead, run Terraform in network-existing/.
#-----------------------------------------------------------------------------
variable "region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region"
}
variable "env" {
  type        = string
  default     = "dev"
  description = "Environment: dev, staging, or prod"
}

variable "app" {
  type        = string
  default     = ""
  description = "Application/project name (used in naming)"
}

variable "owner" {
  type        = string
  default     = ""
  description = "Owner/team for tagging (required when env = prod)"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "VPC CIDR block"
}

variable "single_nat_gateway" {
  type        = bool
  default     = true
  description = "Use one NAT for all AZs (cost-saving); set false for prod HA"
}

variable "allowed_https_cidr_blocks" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "CIDRs allowed for HTTPS (443)"
}

variable "allowed_ssh_cidr_blocks" {
  type        = list(string)
  default     = []
  description = "CIDRs allowed for SSH (22)"
}

variable "db_ingress_ports" {
  type        = list(number)
  default     = [3306, 5432]
  description = "DB ports allowed from VPC (e.g. 3306, 5432)"
}
