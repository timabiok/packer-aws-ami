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
  default     = [8443, 9443]
  description = "ServiceNow node ports (UI and worker)"
}

variable "java_installer" {
  type        = string
  description = "Java package name for installation"
}

packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

locals {
  ports                = jsonencode(var.useful_ports)
  servicenow_uuid      = uuidv4()
  region               = "us-east-1"
  timestamp            = formatdate("YYYYMMDD_hhmmss", timestamp())
  instance_type        = "t3.large"
  iam_instance_profile = "INSTANCESNOW"
  owners               = ["775321136266"]
  ssh_username         = "ec2-user"
  source_ami_name      = "CentOS*"
  root_volume_size     = 100
}

source "amazon-ebs" "servicenow" {
  ami_name                    = "ServiceNow_Rome_Patch5_HF1_${local.timestamp}"
  ami_virtualization_type     = "hvm"
  associate_public_ip_address = true
  instance_type               = local.instance_type
  region                      = local.region
  iam_instance_profile        = local.iam_instance_profile

  subnet_filter {
    filters = {
      "tag:Name" : "stingray-public-*"
    }
    most_free = true
    random    = false
  }

  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = local.root_volume_size
    volume_type           = "gp3"
    delete_on_termination = true
  }

  source_ami_filter {
    filters = {
      name                = local.source_ami_name
      root-device-type    = "ebs"
      virtualization-type = "hvm"
      architecture        = "x86_64"
    }
    most_recent = true
    owners      = local.owners
  }

  ssh_username = local.ssh_username

  tags = {
    Name       = "ServiceNow_Rome_Patch5_HF1_${local.timestamp}"
    Base_AMI   = "CentOS"
    Build_UUID = local.servicenow_uuid
    Created_By = "Packer"
  }
}

build {
  name = "servicenow"

  sources = [
    "amazon-ebs.servicenow"
  ]

  provisioner "shell" {
    script = "servicenow/scripts/install.sh"
    environment_vars = [
      "BUCKET=${var.bucket}",
      "KEY=${var.key}",
      "JSON_PORTS=${local.ports}",
      "JAVA_INSTALLER=${var.java_installer}",
      "REGION=${local.region}"
    ]
  }

  post-processor "manifest" {
    output     = "manifest.json"
    strip_path = true
    strip_time = true
    custom_data = {
      servicenow_uuid = local.servicenow_uuid
    }
  }
}
