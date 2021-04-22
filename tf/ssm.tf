resource "aws_ssm_parameter" "mcare-parameter-datasource" {
  name        = "/mcare/mysql/datasource"
  description = "MySQL URL"
  type        = "String"
  value       = aws_db_instance.mcare-db.endpoint
  tags = {
    "Service" = var.service_name
  }
}

resource "aws_ssm_parameter" "mcare-parameter-user" {
  name        = "/mcare/mysql/user"
  description = "MySQL User"
  type        = "SecureString"
  value       = var.rds_user
  tags = {
    "Service" = var.service_name
  }
}

resource "aws_ssm_parameter" "mcare-parameter-password" {
  name        = "/mcare/mysql/password"
  description = "MySQL Password"
  type        = "SecureString"
  value       = var.rds_password
  tags = {
    "Service" = var.service_name
  }
}