resource "aws_db_instance" "mcare-db" {
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "5.7.31"
  instance_class         = "db.t2.micro"
  name                   = "mcare"
  username               = var.rds_user
  password               = var.rds_password
  parameter_group_name   = "default.mysql5.7"
  skip_final_snapshot    = true
  copy_tags_to_snapshot  = true
  max_allocated_storage  = 1000
  vpc_security_group_ids = [aws_security_group.mcare-db-sg.id]
  db_subnet_group_name   = aws_db_subnet_group.mcare-db-subnet-group.name

  tags = {
    "Service" = "mcare"
  }
}

resource "aws_db_subnet_group" "mcare-db-subnet-group" {
  name        = "mcare-db-subnet-group"
  description = "mcare DB Subnet Group"
  subnet_ids = [aws_subnet.mcare-subnet-public_0.id,
  aws_subnet.mcare-subnet-public_1.id]
}

resource "aws_security_group" "mcare-db-sg" {
  name        = "mcare-db-sg"
  description = "Created by RDS management console"
  vpc_id      = aws_vpc.mcare-vpc.id
}

resource "aws_security_group_rule" "mcare-db-sg-ec2" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = module.mcare-ec2-sg.security_group_id
  security_group_id        = aws_security_group.mcare-db-sg.id
}

resource "aws_security_group_rule" "mcare-db-sg-ecs" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = module.mcare-ecs-sg.security_group_id
  security_group_id        = aws_security_group.mcare-db-sg.id
}

resource "aws_security_group_rule" "mcare-db-sg-egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.mcare-db-sg.id
}