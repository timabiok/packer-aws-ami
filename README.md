# packer-aws-ami

Packer HCL templates for building AWS AMIs. This repo produces two images in a pipeline:

1. **CentOS Base** — CentOS Stream 9 with SSM Agent and Ansible pre-installed.
2. **ServiceNow** — Built on top of the CentOS Base AMI, installs ServiceNow Rome (Patch 5, Hotfix 1) with UI and Worker nodes.

## Repository Structure

```
.
├── .github/workflows/deploy.yml        # CI/CD pipeline
├── centos/
│   ├── aws-centos.pkr.hcl              # Packer template
│   ├── variables.pkr.hcl               # Variable declarations
│   ├── variables.pkrvars.hcl            # Variable values
│   ├── scripts/install.sh              # Provisioning script
│   └── tests/
│       ├── main.tf                     # Smoke test resources
│       ├── variables.tf                # Variable declarations
│       ├── terraform.auto.tfvars.example  # Example variable values (auto-loaded)
│       └── backend.tfbackend.example      # Example S3 backend config
├── servicenow/
│   ├── aws-servicenow.pkr.hcl             # Packer template
│   ├── variables.pkr.hcl                  # Variable declarations
│   ├── variables.pkrvars.hcl               # Variable values
│   ├── scripts/install.sh                 # Provisioning script
│   └── tests/
│       ├── main.tf                        # Smoke test resources
│       ├── variables.tf                   # Variable declarations
│       ├── terraform.auto.tfvars.example  # Example variable values (auto-loaded)
│       └── backend.tfbackend.example      # Example S3 backend config
└── README.md
```

## Prerequisites

- [Packer](https://developer.hashicorp.com/packer/install) >= 1.9
- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.5 (for smoke tests)
- AWS CLI configured with appropriate credentials
- IAM instance profile `INSTANCESNOW` available in target account

## Usage

### CentOS Base AMI

```sh
cd centos

packer init .
packer fmt -check .
packer validate -var-file=variables.pkrvars.hcl .
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

Each AMI has a Terraform configuration under `tests/` that launches an instance for validation. State is stored in S3 using partial backend configuration.

```sh
cd centos/tests   # or servicenow/tests

# Copy example files and fill in your values
cp backend.tfbackend.example backend.tfbackend
cp terraform.auto.tfvars.example terraform.auto.tfvars
# Initialize with your backend config
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
