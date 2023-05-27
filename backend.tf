#backend-sg-security group
resource "aws_security_group" "backend-sg" {
  name        = "backend-sg"
  description = "securitygroup for backend"
  vpc_id      = aws_vpc.stage-vpc.id
  
  ingress {
    description     = "allow 80 from alb"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${aws_security_group.alb-sg.id}"]
  }

  ingress {
    description     = "allow 22 from bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${aws_security_group.bastion-sg.id}"]
  }
  ingress {
    description     = "allow ssh from jenkins"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${aws_security_group.jenkins-sg.id}"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "backend-sg"
  }
}
#backend-sguserdata
/* data "template_file" "backend-sguser" {
  template = file("backend-sg.sh")

} */
# backend instance
resource "aws_instance" "backend" {
  ami                    = data.aws_ami.ami_id.id
  instance_type          = var.instance_type_1
  subnet_id              = aws_subnet.privatesubnet[1].id
  vpc_security_group_ids = [aws_security_group.backend-sg.id]
  key_name               = aws_key_pair.deployer.id
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
  #user_data              = data.template_file.backend-sguser.rendered
#   user_data = file("scripts/keygen.sh")
  tags = {
    Name = "backend"
  }
}

# alb target-group
resource "aws_lb_target_group" "backend-tg" {
  name     = "backend-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.stage-vpc.id
}

resource "aws_lb_target_group_attachment" "backend-attachment" {
  target_group_arn = aws_lb_target_group.backend-tg.arn
  target_id        = aws_instance.backend.id
  port             = 80
}

# alb-listner_rule
resource "aws_lb_listener_rule" "backend-hostbased" {
  listener_arn = aws_lb_listener.alb-listener.arn
  #   priority     = 98

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend-tg.arn
  }

  condition {
    host_header {
      values = ["backend.siva.quest"]
    }
  }
}