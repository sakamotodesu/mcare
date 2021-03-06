resource "aws_s3_bucket" "mcare-alb-log" {
  bucket = "sakamotodesu-${var.service_name}-alb-log"
  lifecycle_rule {
    enabled = true

    expiration {
      days = "180"
    }
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }

  }
  provisioner "local-exec" {
    when    = destroy
    command = "aws s3 rm s3://sakamotodesu-mcare-alb-log/AWSLogs/ --recursive" //変数は使えないみたい
  }
  tags = {
    "Service" = var.service_name
  }
}

resource "aws_s3_bucket_policy" "mcare-alb-log-policy" {
  bucket = aws_s3_bucket.mcare-alb-log.id
  policy = data.aws_iam_policy_document.alb_log.json
}

data "aws_iam_policy_document" "alb_log" {
  statement {
    effect = "Allow"
    actions = [
    "s3:PutObject"]
    resources = [
    "arn:aws:s3:::${aws_s3_bucket.mcare-alb-log.id}/*"]

    principals {
      type = "AWS"
      identifiers = [
      "582318560864"]
    }
  }
}