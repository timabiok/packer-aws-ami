packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

locals {
  ports           = jsonencode(var.useful_ports)
  servicenow_uuid = uuidv4()
  timestamp       = formatdate("YYYYMMDD_hhmmss", timestamp())
}

source "amazon-ebs" "servicenow" {
  ami_name                    = "ServiceNow_Rome_Patch5_HF1_${local.timestamp}"
  ami_virtualization_type     = "hvm"
  associate_public_ip_address = true
  instance_type               = var.instance_type
  region                      = var.region
  iam_instance_profile        = var.iam_instance_profile

  subnet_filter {
    filters = {
      "tag:Name" : var.subnet_filter_name
    }
    most_free = true
    random    = false
  }

  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    delete_on_termination = true
  }

  source_ami_filter {
    filters = {
      name                = var.source_ami_name
      root-device-type    = "ebs"
      virtualization-type = "hvm"
      architecture        = "x86_64"
    }
    most_recent = true
    owners      = var.source_ami_owners
  }

  ssh_username = var.ssh_username

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
      "REGION=${var.region}"
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
