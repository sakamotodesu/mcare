// subnet group
// instance
// TODO security group

resource "aws_db_instance" "mcare-db" {
  allocated_storage     = 20
  engine                = "mysql"
  engine_version        = "5.7.31"
  instance_class        = "db.t2.micro"
  name                  = "mcare_db"
  username              = "admin"
  parameter_group_name  = "default.mysql5.7"
  skip_final_snapshot   = true
  copy_tags_to_snapshot = true
  max_allocated_storage = 1000
  // TODO vpc_security_group_ids
}

resource "aws_db_subnet_group" "mcare-db-subnet-group" {
  name        = "mcare-db-subnet-group"
  description = "mcare DB Subnet Group"
  subnet_ids  = [aws_subnet.mcare-subnet-public_0.id, aws_subnet.mcare-subnet-public_1.id]
}