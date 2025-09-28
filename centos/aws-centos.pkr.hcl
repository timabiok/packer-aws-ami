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
  region      = "us-east-1"
  timestamp   = timestamp() 
  
}

source "amazon-ebs" "centos" {
  ami_name                    = "CentOS-Stream-9-Base-${local.timestamp}"
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
      name                = "CentOS-Stream-9-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
      architecture        = "x86_64"
      
    }
    most_recent = true
    owners      = ["679593333241"]
  }
  ssh_username = "ec2-user"
}

build {

  provisioner "shell" {
    script = "scripts/install.sh"
    environment_vars = [
      "REGION=${local.region}"
    ]
  }

  name = "CentOS-Stream-9-build-${local.timestamp}"
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
