#apache-security group
resource "aws_security_group" "frontend-sg" {
  name        = "frontend-sg"
  description = "securitygroup for frontend"
  vpc_id      = aws_vpc.stage-vpc.id
  
  ingress {
    description     = "allow ssh from bastion"
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
  ingress {
    description     = "allow 3000 from loadbalancer"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = ["${aws_security_group.alb-sg.id}"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "frontend-sg"
  }
}
#apacheuserdata
/* data "template_file" "apacheuser" {
  template = file("apache.sh")

} */
# apache instance
resource "aws_instance" "frontend" {
  ami                    = data.aws_ami.ami_id.id
  instance_type          = var.instance_type_1
  subnet_id              = aws_subnet.privatesubnet[1].id
  vpc_security_group_ids = [aws_security_group.frontend-sg.id]
  key_name               = aws_key_pair.deployer.id
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
  #user_data              = data.template_file.apacheuser.rendered
#   user_data = file("scripts/keygen.sh")
  tags = {
    Name = "frontend"
  }
}

# alb target-group
resource "aws_lb_target_group" "frontend-tg" {
  name     = "frontend-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = aws_vpc.stage-vpc.id
}

resource "aws_lb_target_group_attachment" "frontend-attachment" {
  target_group_arn = aws_lb_target_group.frontend-tg.arn
  target_id        = aws_instance.frontend.id
  port             = 80
}



# alb-listner_rule
resource "aws_lb_listener_rule" "hostbased-frontend" {
  listener_arn = aws_lb_listener.alb-listener.arn
  #   priority     = 98

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend-tg.arn
  }

  condition {
    host_header {
      values = ["frontend.siva.quest"]
    }
  }
}