output "vpc_id" {
  description = "VPC ID for builds and tests"
  value       = var.existing_vpc_id
}

output "vpc_cidr_block" {
  description = "VPC CIDR block"
  value       = data.aws_vpc.existing.cidr_block
}

output "public_subnet_ids" {
  description = "Subnet IDs for Packer/build instances"
  value       = var.existing_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs (empty when using existing)"
  value       = []
}

output "app_security_group_id" {
  description = "First security group ID for build/test instances"
  value       = length(var.existing_security_group_ids) > 0 ? var.existing_security_group_ids[0] : null
}

output "app_security_group_ids" {
  description = "Security group IDs for build/test instances"
  value       = var.existing_security_group_ids
}

output "build_subnet_id" {
  description = "Single subnet ID for Packer (first of existing_subnet_ids)"
  value       = length(var.existing_subnet_ids) > 0 ? var.existing_subnet_ids[0] : null
}

output "build_security_group_ids" {
  description = "Security group IDs for Packer build instances"
  value       = var.existing_security_group_ids
}
