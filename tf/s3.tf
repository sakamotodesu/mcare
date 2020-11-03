resource "aws_s3_bucket" "mcare-alb-log" {
  bucket = "sakamotodesu-${var.service_name}-alb-log"
  lifecycle_rule {
    enabled = true

    expiration {
      days = "180"
    }
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