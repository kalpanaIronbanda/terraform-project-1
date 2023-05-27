#apache-security group
resource "aws_security_group" "jenkins-sg" {
  name        = "jenkins-sg"
  description = "secuity group for jenkins"
  vpc_id      = aws_vpc.stage-vpc.id

  ingress {
    description     = "allow ssh from bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${aws_security_group.bastion-sg.id}"]
  }
  ingress {
    description = "allow jenkins from alb"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
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
    Name = "jenkins-sg"
  }
}
#apacheuserdata
/* data "template_file" "jenkinsuser" {
  template = file("jenkins.sh")

} */
# apache instance
resource "aws_instance" "jenkins" {
  ami                    = data.aws_ami.ami_id.id
  instance_type          = var.instance_type_1
  subnet_id              = aws_subnet.privatesubnet[0].id
  vpc_security_group_ids = [aws_security_group.jenkins-sg.id]
  key_name               = aws_key_pair.deployer.id
  #user_data              = data.template_file.jenkinsuser.rendered
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
  user_data            = file("scripts/jenkins.sh")
  tags = {
    Name = "jenkins"
  }
}

# alb target-group
resource "aws_lb_target_group" "jenkins-tg" {
  name     = "jenkins-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.stage-vpc.id
}

resource "aws_lb_target_group_attachment" "jenkins-attachment" {
  target_group_arn = aws_lb_target_group.jenkins-tg.arn
  target_id        = aws_instance.jenkins.id
  port             = 8080
}



# alb-listner_rule
resource "aws_lb_listener_rule" "jenkins-hostbased" {
  listener_arn = aws_lb_listener.alb-listener.arn
  #   priority     = 98

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins-tg.arn
  }

  condition {
    host_header {
      values = ["jenkins.siva.quest"]
    }
  }
}


# alb target-group
# resource "aws_lb_target_group" "siva-tg-nodeexporter" {
#   name     = "tg-node"
#   port     = 9100
#   protocol = "HTTP"
#   vpc_id   = aws_vpc.stage-vpc.id
# }

# resource "aws_lb_target_group_attachment" "siva-tg-attachment-node-exporter" {
#   target_group_arn = aws_lb_target_group.siva-tg-nodeexporter.arn
#   target_id        = aws_instance.jenkins.id
#   port             = 9100
# }



# # alb-listner_rule
# resource "aws_lb_listener_rule" "siva-nodeexporter-hostbased" {
#   listener_arn = aws_lb_listener.siva-alb-listener.arn
#   #   priority     = 98

#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.siva-tg-nodeexporter.arn
#   }

#   condition {
#     host_header {
#       values = ["node-exporter.siva.quest"]
#     }
#   }
# }
