variable "bucket" {}
variable "key" {}
variable "useful_ports" {
  type    = list(number)
  default = [0]
}
variable "java_installer" {}

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
  timestamp            = formatdate("YYYYMMDD__hhmmss", timestamp())
  instance_type        = "t3.large"
  iam_instance_profile = "INSTANCESNOW"
  owners               = ["775321136266"]
  ssh_username         = "ec2-user"
  source_ami_name      = "CentOS*"

}

source "amazon-ebs" "servicenow" {
  ami_name                    = "glide_rome_06_23_2021__patch5_hotfix1_${local.timestamp}"
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

  ami_block_device_mappings {
    device_name           = "/dev/xvda"
    volume_size           = 100
    volume_type           = "gp3"
    delete_on_termination = true
  }


  # root_block_device {
  #   volume_size = 100     # Size in GB
  #   volume_type = "gp3"
  #   delete_on_termination = true
  # }


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
}

build {

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

  name = "centos-9-stream"
  sources = [
    "amazon-ebs.servicenow"
  ]

  post-processor "manifest" {
    output     = "manifest.json"
    strip_path = true
    strip_time = true
    custom_data = {
      servicenow_uuid = "${local.servicenow_uuid}"
    }
  }
}
