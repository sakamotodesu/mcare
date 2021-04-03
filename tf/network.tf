resource "aws_vpc" "mcare-vpc" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = var.service_name
  }
}

resource "aws_subnet" "mcare-subnet-public_0" {
  vpc_id                  = aws_vpc.mcare-vpc.id
  cidr_block              = "10.1.1.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.service_name}-subnet-public_0"
  }
}

resource "aws_subnet" "mcare-subnet-public_1" {
  vpc_id                  = aws_vpc.mcare-vpc.id
  cidr_block              = "10.1.2.0/24"
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.service_name}-subnet-public_1"
  }
}

resource "aws_internet_gateway" "mcare-igw" {
  vpc_id = aws_vpc.mcare-vpc.id

  tags = {
    "Service" = var.service_name
  }
}

resource "aws_route_table" "mcare-route-table-public" {
  vpc_id = aws_vpc.mcare-vpc.id
}

resource "aws_route" "mcare-route-public" {
  route_table_id         = aws_route_table.mcare-route-table-public.id
  gateway_id             = aws_internet_gateway.mcare-igw.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "public_0" {
  subnet_id      = aws_subnet.mcare-subnet-public_0.id
  route_table_id = aws_route_table.mcare-route-table-public.id
}

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.mcare-subnet-public_1.id
  route_table_id = aws_route_table.mcare-route-table-public.id
}

module "mcare-vpc-sg" {
  source = "./security_group"
  name   = "${var.service_name}-vpc-sg"
  vpc_id = aws_vpc.mcare-vpc.id
  port   = 80
  cidr_blocks = [
  "0.0.0.0/0"]
}


resource "aws_lb" "mcare-alb" {
  name                       = "${var.service_name}-alb"
  load_balancer_type         = "application"
  internal                   = false
  idle_timeout               = 60
  enable_deletion_protection = false

  subnets = [
    aws_subnet.mcare-subnet-public_0.id,
    aws_subnet.mcare-subnet-public_1.id,
  ]

  access_logs {
    bucket  = aws_s3_bucket.mcare-alb-log.id
    enabled = true
  }

  security_groups = [
    module.http_sg.security_group_id,
    module.https_sg.security_group_id,
    module.http_redirect_sg.security_group_id,
  ]

  tags = {
    "Service" = var.service_name
  }
}

module "http_sg" {
  source = "./security_group"
  name   = "http-sg"
  vpc_id = aws_vpc.mcare-vpc.id
  port   = 80
  cidr_blocks = [
  "0.0.0.0/0"]
}

module "https_sg" {
  source = "./security_group"
  name   = "https-sg"
  vpc_id = aws_vpc.mcare-vpc.id
  port   = 443
  cidr_blocks = [
  "0.0.0.0/0"]
}

module "http_redirect_sg" {
  source = "./security_group"
  name   = "http-redirect-sg"
  vpc_id = aws_vpc.mcare-vpc.id
  port   = 8080
  cidr_blocks = [
  "0.0.0.0/0"]
}

output "alb_dns_name" {
  value = aws_lb.mcare-alb.name
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.mcare-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

data "aws_route53_zone" "sakamoto-ninja" {
  name = "sakamoto.ninja"
}

resource "aws_route53_record" "mcare-record" {
  zone_id = data.aws_route53_zone.sakamoto-ninja.zone_id
  name    = "mcare.sakamoto.ninja"
  type    = "A"

  alias {
    name                   = aws_lb.mcare-alb.dns_name
    zone_id                = aws_lb.mcare-alb.zone_id
    evaluate_target_health = false
  }
}

resource "aws_acm_certificate" "sakamoto-ninja-mcare-acm" {
  domain_name               = aws_route53_record.mcare-record.name
  subject_alternative_names = []
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "sakamoto-ninja-mcare-certificate" {
  name = aws_acm_certificate.sakamoto-ninja-mcare-acm.domain_validation_options[0].resource_record_name
  type = aws_acm_certificate.sakamoto-ninja-mcare-acm.domain_validation_options[0].resource_record_type
  records = [
  aws_acm_certificate.sakamoto-ninja-mcare-acm.domain_validation_options[0].resource_record_value]
  zone_id = data.aws_route53_zone.sakamoto-ninja.id
  ttl     = 60
}

resource "aws_acm_certificate_validation" "sakamoto-ninja-validation" {
  certificate_arn = aws_acm_certificate.sakamoto-ninja-mcare-acm.arn
  validation_record_fqdns = [
  aws_route53_record.sakamoto-ninja-mcare-certificate.fqdn]
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.mcare-alb.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.sakamoto-ninja-mcare-acm.arn
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mcare-alb-target.arn
  }
}

resource "aws_lb_target_group" "mcare-alb-target" {
  name                 = "${var.service_name}-alb-target"
  vpc_id               = aws_vpc.mcare-vpc.id
  target_type          = "ip"
  port                 = 8080
  protocol             = "HTTP"
  deregistration_delay = 300

  health_check {
    path                = "/"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = 200
    port                = "traffic-port"
    protocol            = "HTTP"
  }

  depends_on = [
  aws_lb.mcare-alb]
}

resource "aws_route53_record" "mcare-bastion-record" {
  zone_id = data.aws_route53_zone.sakamoto-ninja.zone_id
  name    = "bastion.mcare.sakamoto.ninja"
  type    = "CNAME"
  ttl     = 300

  records = [
    aws_instance.mcare-ec2.public_dns
  ]
}