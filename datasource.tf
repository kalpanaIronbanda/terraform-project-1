data "aws_ami" "ami_id" {

  most_recent = true
  owners      = ["137112412989"]

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "tag:Name"
    values = ["amazon-linux"]
  }
}


