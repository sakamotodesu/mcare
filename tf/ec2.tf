data "aws_ami" "mcare-ami" {
  most_recent = true
  owners = [
  "amazon"]

  filter {
    name = "architecture"
    values = [
    "x86_64"]
  }

  filter {
    name = "root-device-type"
    values = [
    "ebs"]
  }

  filter {
    name = "name"
    values = [
    "amzn2-ami-hvm-*"]
  }

  filter {
    name = "virtualization-type"
    values = [
    "hvm"]
  }

  filter {
    name = "block-device-mapping.volume-type"
    values = [
    "gp2"]
  }

  filter {
    name = "state"
    values = [
    "available"]
  }
}

resource "aws_instance" "mcare-ec2" {
  ami = data.aws_ami.mcare-ami.image_id
  vpc_security_group_ids = [
  module.mcare-ec2-sg.security_group_id]
  subnet_id     = aws_subnet.mcare-subnet-public_0.id
  key_name      = "mcare-keypair"
  instance_type = "t2.micro"

  tags = {
    Name = "mcare-bastion"
  }
}

module "mcare-ec2-sg" {
  source = "./security_group"
  name   = "mcare-ec2-sg"
  vpc_id = aws_vpc.mcare-vpc.id
  port   = 22
  cidr_blocks = [
  "0.0.0.0/0"]
}