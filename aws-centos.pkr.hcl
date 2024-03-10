# variable "bucket" {}
# variable "key" {}
# variable "port" {}
# variable "java_installer" {}

packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

locals {
  centos_uuid    = uuidv4()
  bucket         = "servicenow-abiok"
  useful_ports   = [8443, 9443]
  key            = "abiok/docker-servicenow/snow/rome-patch5-1/glide-rome-06-23-2021__patch5-hotfix1-01-06-2022_01-12-2022_1753.zip"
  ports          = jsonencode(local.useful_ports)
  java_installer = "java-1.8.0-openjdk-devel"
}

source "amazon-ebs" "centos" {
  ami_name                    = "centos-rome-patch-1-ui-and-worker"
  ami_virtualization_type     = "hvm"
  associate_public_ip_address = true
  instance_type               = "t2.micro"
  region                      = "us-east-1"
  // profile                     = "nonprod"
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
      name                = "Cent*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["775321136266"]
  }
  ssh_username = "centos"
}

build {

  provisioner "shell" {
    # execute_command  = "sudo -S {{.Path}} {{.EnvVarFile}}"
    script = "scripts/install.sh"
    # use_env_var_file = true
    environment_vars = [
      "BUCKET=${local.bucket}",
      "KEY=${local.key}",
      "JSON_PORTS=${local.ports}",
      "JAVA_INSTALLER=${local.java_installer}"
    ]
  }

  name = "centos-rome-release"
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
