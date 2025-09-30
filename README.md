# packer-aws-ami

This repository contains a Packer HCL template to build an AWS CentOS AMI.

## Quick commands

Format, validate and build the template using the explicit template filename so commands are unambiguous.

```sh
# format the template
packer fmt aws-centos.pkr.hcl

# validate the template (optionally load the variables file)
packer validate -var-file="variables.pkrvars.hcl" aws-centos.pkr.hcl

# build the AMI (normal and debug)
packer build -var-file="variables.pkrvars.hcl" aws-centos.pkr.hcl
packer build -debug -var-file="variables.pkrvars.hcl" aws-centos.pkr.hcl

# ssh into a provisioned instance (example)
ssh -i /path/key-pair-name.pem instance-user-name@instance-public-dns-name

# deregister an AMI
aws ec2 deregister-image --image-id ami-*************
```

Notes:

- Ensure AWS credentials and profile are configured (e.g. `export AWS_PROFILE=nonprod`).
- Update `variables.pkrvars.hcl` if you need to change instance type, region, key pair, or other variables.
- Run `packer validate` before `packer build` to catch template issues early.
