resource "aws_launch_template" "template" {
  name_prefix   = "test"
  image_id      = "ami-0df61c16dd7bd6280"
  instance_type = "t2.micro"
  key_name      = "ec2_centos_kp"
  # vpc_security_group_ids = ["sg-06f7be65c3c3a3190"]

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = ["sg-06f7be65c3c3a3190"]
    subnet_id                   = "subnet-0f3124553b76fcd46"
  }

  iam_instance_profile {
    name = "INSTANCESNOW"
  }

  user_data = filebase64("${path.module}/userdata.sh")
}

resource "aws_autoscaling_group" "autoscale" {
  name                 = "test-autoscaling-group"
  desired_capacity     = 1
  max_size             = 1
  min_size             = 1
  health_check_type    = "EC2"
  termination_policies = ["OldestInstance"]
  vpc_zone_identifier  = ["subnet-0f3124553b76fcd46", "subnet-0ad2590b8b177fde7", "subnet-0b9ed8367a72bd40a"]


  launch_template {
    id      = aws_launch_template.template.id
    version = "$Latest"
  }
}


# output "dns" {
#   value="${aws_launch_template.template}"
# }
