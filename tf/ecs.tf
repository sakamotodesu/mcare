resource "aws_ecr_repository" "mcare" {
  name                 = var.service_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }

  tags = {
    "Service" = var.service_name
  }
}

data "aws_iam_policy_document" "mcare-policy-document" {
  version = "2008-10-17"
  statement {
    principals {
      type = "AWS"
      identifiers = [
      "arn:aws:iam::616703994274:user/bittrader-ecs-ecr"]
    }
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeRepositories",
      "ecr:GetRepositoryPolicy",
      "ecr:ListImages",
      "ecr:DeleteRepository",
      "ecr:BatchDeleteImage",
      "ecr:SetRepositoryPolicy",
      "ecr:DeleteRepositoryPolicy"
    ]
    effect = "Allow"
    sid    = "circleci_allow"
  }
}
resource "aws_ecr_repository_policy" "mcare-policy" {
  repository = aws_ecr_repository.mcare.name
  policy     = data.aws_iam_policy_document.mcare-policy-document.json
}

resource "aws_ecs_cluster" "mcare-cluster" {
  name = "${var.service_name}-cluster"

  tags = {
    "Service" = var.service_name
  }
}

resource "aws_ecs_service" "mcare-service" {
  name             = "${var.service_name}-service"
  cluster          = aws_ecs_cluster.mcare-cluster.id
  task_definition  = aws_ecs_task_definition.mcare-service.arn
  desired_count    = 1
  launch_type      = "FARGATE"
  platform_version = "1.3.0"

  network_configuration {
    assign_public_ip = true
    security_groups = [
    module.mcare-ecs-sg.security_group_id]

    subnets = [
      aws_subnet.mcare-subnet-public_0.id,
      aws_subnet.mcare-subnet-public_1.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.mcare-alb-target.arn
    container_name   = "${var.service_name}-service"
    container_port   = 8080
  }

  lifecycle {
    ignore_changes = [
    task_definition]
  }
  tags = {
    "Service" = var.service_name
  }
}

module "mcare-ecs-sg" {
  source = "./security_group"
  name   = "mcare-ecs-sg"
  vpc_id = aws_vpc.mcare-vpc.id
  port   = 8080
  cidr_blocks = [
  aws_vpc.mcare-vpc.cidr_block]
}


resource "aws_ecs_task_definition" "mcare-service" {
  family             = "${var.service_name}-service"
  cpu                = 256
  memory             = 512
  network_mode       = "awsvpc"
  execution_role_arn = "arn:aws:iam::616703994274:role/ecsTaskExecutionRole"
  requires_compatibilities = [
  "FARGATE"]
  container_definitions = file("task-definitions/mcare-service.json")
}