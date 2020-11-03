// TODO mcareユーザ作る
data "aws_iam_user" "mcare-ecs-ecr" {
  user_name = "bittrader-ecs-ecr"
}

