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
  ports       = jsonencode(var.useful_ports)
  centos_uuid = uuidv4()
  region      = "us-east-1"
  timestamp   = timestamp()
}

source "amazon-ebs" "centos" {
  ami_name                    = "glide_rome_06_23_2021__patch5_hotfix1"
  ami_virtualization_type     = "hvm"
  associate_public_ip_address = true
  instance_type               = "t2.micro"
  region                      = "us-east-1"
  iam_instance_profile        = "INSTANCESNOW"
  subnet_filter {
    filters = {
      "tag:Name" : "stingray-public-*"
    }

    most_free = true
    random    = false
  }

  source_ami_filter {
    filters = {
      name                = "CentOS-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
      architecture        = "x86_64"
      
    }
    most_recent = true
    owners      = ["775321136266"]
  }
  ssh_username = "ec2-user"
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

  name = "glide_rome_06_23_2021__patch5_hotfix1_build"
  sources = [
    "amazon-ebs.centos"
  ]

  post-processor "manifest" {
    output     = "manifest.json"
    strip_path = true
    strip_time = true
    custom_data = {
      centos_uuid = "${local.centos_uuid}"
    }
  }
}
