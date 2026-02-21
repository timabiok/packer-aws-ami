packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

locals {
  centos_uuid          = uuidv4()
  region               = "us-east-1"
  timestamp            = formatdate("YYYYMMDD_hhmmss", timestamp())
  instance_type        = "t3.large"
  iam_instance_profile = "INSTANCESNOW"
  owners               = ["679593333241"]
  ssh_username         = "ec2-user"
  source_ami_name      = "CentOS-Stream-9-*"
}

source "amazon-ebs" "centos" {
  ami_name                    = "CentOS_Stream_9_Base_${local.timestamp}"
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

  provisioner "shell" {
    script = "centos/scripts/install.sh"
    environment_vars = [
      "REGION=${local.region}"
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
