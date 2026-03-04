region               = "us-east-1"
instance_type        = "t3.large"
iam_instance_profile = "INSTANCESNOW"
source_ami_owners    = ["679593333241"]
ssh_username         = "ec2-user"
source_ami_name      = "CentOS-Stream-9-*"
subnet_filter_name   = "stingray-public-*"
