resource "aws_security_group" "rds-sg" {
  name        = "rds-sg"
  description = "security group for rds"
  vpc_id      = aws_vpc.stage-vpc.id

  ingress {
    description     = "allow rds from backend"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = ["${aws_security_group.backend-sg.id}"]
  }

  ingress {
    description     = "this is inbound rule"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = ["${aws_security_group.bastion-sg.id}"]

  }
}
resource "aws_db_subnet_group" "db-subnetgroup" {
  name = "db-subnetgroup"
  # subnet_ids = [module.vpc.aws_subnet.datasubnet[0].id, module.vpcaws_subnet.datasubnet[1].id, module.vpcaws_subnet.datasubnet[2].id]
  #subnet_ids = [var.datasubnet1, var.datasubnet2, var.datasubnet3] 
  subnet_ids = [aws_subnet.datasubnet[0].id, aws_subnet.datasubnet[1].id, aws_subnet.datasubnet[2].id]
  tags = {
    Name = "rdssubnet-group"
  }
}

resource "aws_db_instance" "default" {
  allocated_storage      = 10
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t3.micro"
  db_name                = "PythonAppDb"
  username               = "thanshi"
  password               = "thanshi123"
  parameter_group_name   = "default.mysql5.7"
  db_subnet_group_name   = aws_db_subnet_group.db-subnetgroup.name
  vpc_security_group_ids = ["${aws_security_group.rds-sg.id}"]
  skip_final_snapshot    = true
  tags = {
    "name" = "pythonDb"
  }
}

