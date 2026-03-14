# packer-aws-ami

Packer HCL templates for building AWS AMIs. This repo produces two images in a pipeline:

1. **CentOS Base** — CentOS Stream 9 with SSM Agent and Ansible pre-installed.
2. **ServiceNow** — Built on top of the CentOS Base AMI, installs ServiceNow Rome (Patch 5, Hotfix 1) with UI and Worker nodes.

The repo does **not** assume any existing VPC or subnets: you can either **create** a network via the included [terraform-aws-vpc](https://github.com/timabiok/terraform-aws-vpc) module or **provide** existing resource IDs.

## Repository Structure

```
.
├── .github/workflows/deploy.yml        # CI/CD pipeline
├── network/                            # Create VPC via terraform-aws-vpc module
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── versions.tf
│   └── terraform.auto.tfvars.example
├── network-existing/                   # Use existing VPC/subnet/SG IDs (same outputs)
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── versions.tf
│   └── terraform.auto.tfvars.example
├── centos/
│   ├── aws-centos.pkr.hcl              # Packer template
│   ├── variables.pkr.hcl               # Variable declarations
│   ├── variables.pkrvars.hcl           # Variable values
│   ├── scripts/install.sh              # Provisioning script
│   └── tests/
│       ├── main.tf                     # Smoke test resources
│       ├── variables.tf
│       ├── terraform.auto.tfvars.example
│       └── backend.tfbackend.example
├── servicenow/
│   ├── aws-servicenow.pkr.hcl
│   ├── variables.pkr.hcl
│   ├── variables.pkrvars.hcl
│   ├── scripts/install.sh
│   └── tests/
│       ├── main.tf
│       ├── variables.tf
│       ├── terraform.auto.tfvars.example
│       └── backend.tfbackend.example
└── README.md
```

## Prerequisites

- [Packer](https://developer.hashicorp.com/packer/install) >= 1.9
- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.5 (for network and smoke tests)
- AWS CLI configured with appropriate credentials
- IAM instance profile `INSTANCESNOW` available in target account

## Network: Create or Use Existing

The repo does not assume a VPC exists. Either **create** one via the [terraform-aws-vpc](https://github.com/timabiok/terraform-aws-vpc) module or **provide** existing resource IDs.

### Option A — Create network (`network/`)

```sh
cd network
cp terraform.auto.tfvars.example terraform.auto.tfvars   # edit if needed
terraform init -backend-config=backend.tfbackend       # if using S3 backend
terraform apply
```

Use outputs for Packer and tests: `build_subnet_id`, `build_security_group_ids`. In tests, set `use_network_state = true` and `terraform_state_bucket` (and leave `network_state_key` default).

### Option B — Use existing network (`network-existing/`)

```sh
cd network-existing
cp terraform.auto.tfvars.example terraform.auto.tfvars
# Set existing_vpc_id, existing_subnet_ids, existing_security_group_ids
terraform init -backend-config=backend.tfbackend
terraform apply
```

Same outputs as Option A. In tests, set `use_network_state = true`, `terraform_state_bucket`, and `network_state_key = "packer-aws-ami/network-existing/terraform.tfstate"`.

## Usage

### CentOS Base AMI

Either pass subnet and security groups from the network layer, or use tag-based `subnet_filter_name` (and optional `security_group_ids`).

```sh
cd centos

packer init .
packer fmt -check .
packer validate -var-file=variables.pkrvars.hcl .

# With network created first (use network outputs):
# packer build -var-file=variables.pkrvars.hcl -var "subnet_id=$(cd ../network && terraform output -raw build_subnet_id)" -var "security_group_ids=[$(cd ../network && terraform output -raw build_security_group_ids)]" .

packer build -var-file=variables.pkrvars.hcl .
```

### ServiceNow AMI

```sh
cd servicenow

packer init .
packer fmt -check .
packer validate -var-file=variables.pkrvars.hcl .
packer build -var-file=variables.pkrvars.hcl .
```

### Smoke Tests

Each AMI has a Terraform configuration under `tests/` that launches an instance for validation. You can either pass `subnet_id` and `security_group_ids` (e.g. from network outputs) or set `use_network_state = true` and `terraform_state_bucket` so tests read from the network state.

```sh
cd centos/tests   # or servicenow/tests

cp backend.tfbackend.example backend.tfbackend
cp terraform.auto.tfvars.example terraform.auto.tfvars
# Edit terraform.auto.tfvars: set subnet_id and security_group_ids, or use_network_state = true and terraform_state_bucket

terraform init -backend-config=backend.tfbackend
terraform plan
terraform apply
terraform destroy
```

## CI/CD

The GitHub Actions workflow (`.github/workflows/deploy.yml`) runs on pushes to `main`:

1. Builds the CentOS Base AMI (`packer fmt -check` → `validate` → `build`)
2. Builds the ServiceNow AMI (depends on step 1)

### Required Secrets & Variables

| Type     | Name                    | Description              |
|----------|-------------------------|--------------------------|
| Secret   | `AWS_ACCESS_KEY_ID`     | AWS access key           |
| Secret   | `AWS_SECRET_ACCESS_KEY` | AWS secret key           |
| Variable | `AWS_REGION`            | Target AWS region        |

## Deregistering an AMI

```sh
aws ec2 deregister-image --image-id ami-XXXXXXXXXXXX
```
