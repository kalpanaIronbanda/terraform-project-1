# resource "null_resource" "execute_commands" {
#   provisioner "local-exec" {
#     command = <<EOF
#       ssh -o StrictHostKeyChecking=no ec2-user@${aws_instance.bastion.public_ip} \
#       "sudo apt-get install -y nginx"
#     EOF
#   }

#   depends_on = [aws_instance.bastion]
# }