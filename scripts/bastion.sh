#!/bin/bash
touch ~/.ssh/id_rsa
echo "${file("~/.ssh/id_rsa")}" >> /home/ec2-user/.ssh/id_rsa
chmod 600 /home/ec2-user/.ssh/id_rsa
chown -R ec2-user:ec2-user /home/ec2-user/.ssh/id_rsa
