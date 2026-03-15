packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

locals {
  centos_uuid = uuidv4()
  timestamp   = formatdate("YYYYMMDD_hhmmss", timestamp())
}

source "amazon-ebs" "centos" {
  ami_name                    = "CentOS_Stream_9_Base_${local.timestamp}"
  ami_virtualization_type     = "hvm"
  associate_public_ip_address = true
  instance_type               = var.instance_type
  region                      = var.region
  iam_instance_profile        = var.iam_instance_profile

  subnet_id            = var.subnet_id
  security_group_ids   = length(var.security_group_ids) > 0 ? var.security_group_ids : null
  subnet_filter {
    filters = {
      "tag:Name" : var.subnet_filter_name != null ? var.subnet_filter_name : "*"
    }
    most_free = true
    random    = false
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
    Name       = "CentOS_Stream_9_Base_${local.timestamp}"
    Base_AMI   = "CentOS-Stream-9"
    Build_UUID = local.centos_uuid
    Created_By = "Packer"
  }
}

build {
  name = "centos-9-stream"

  sources = [
    "amazon-ebs.centos"
  ]

  provisioner "file" {
    source      = "centos/scripts/dnf-automatic.conf"
    destination = "/tmp/dnf-automatic.conf"
  }

  provisioner "shell" {
    script = "centos/scripts/install.sh"
    environment_vars = [
      "REGION=${var.region}"
    ]
  }

  post-processor "manifest" {
    output     = "manifest.json"
    strip_path = true
    strip_time = true
    custom_data = {
      centos_uuid = local.centos_uuid
    }
  }
}
