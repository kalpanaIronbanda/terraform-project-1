# bastion - security group
resource "aws_security_group" "bastion-sg" {
  name        = "bastion-sg"
  description = "securitygroup for bastion"
  vpc_id      = aws_vpc.stage-vpc.id

  ingress {
    description = "this is inbound rule"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "bastion-sg"
  }
}
# bastion instance
resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.ami_id.id
  instance_type          = var.instance_type_1
  subnet_id              = aws_subnet.publicsubnet[0].id
  vpc_security_group_ids = [aws_security_group.bastion-sg.id]
  key_name               = aws_key_pair.deployer.id
  user_data            = file("scripts/bastion.sh")
  # <<-EOF
  #   #!/bin/bash
  #   touch ~/.ssh/id_rsa
  #   echo "${file("~/.ssh/id_rsa")}" >> /home/ec2-user/.ssh/id_rsa
  #   chmod 600 /home/ec2-user/.ssh/id_rsa
  #   chown -R ec2-user:ec2-user /home/ec2-user/.ssh/id_rsa
  # EOF
  tags = {
    Name = "bastion"
  }
}