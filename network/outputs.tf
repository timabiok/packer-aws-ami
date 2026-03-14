#-----------------------------------------------------------------------------
# Outputs from terraform-aws-vpc module
#-----------------------------------------------------------------------------
output "vpc_id" {
  description = "VPC ID for builds and tests"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "VPC CIDR block"
  value       = module.vpc.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "Public subnet IDs (for Packer/build instances)"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs (for app workloads)"
  value       = module.vpc.private_subnet_ids
}

output "app_security_group_id" {
  description = "Application security group ID for build/test instances"
  value       = module.vpc.app_security_group_id
}

output "app_security_group_ids" {
  description = "List of security group IDs for build/test instances"
  value       = module.vpc.app_security_group_id != null ? [module.vpc.app_security_group_id] : []
}

# Convenience: single subnet and SG for Packer
output "build_subnet_id" {
  description = "Single subnet ID for Packer (first public subnet)"
  value       = length(module.vpc.public_subnet_ids) > 0 ? module.vpc.public_subnet_ids[0] : null
}

output "build_security_group_ids" {
  description = "Security group IDs for Packer build instances"
  value       = module.vpc.app_security_group_id != null ? [module.vpc.app_security_group_id] : []
}
