terraform {
  backend "s3" {
    bucket = "sakamotodesu-mcare-tfstate"
    key    = "terraform.tfstate"
    region = "ap-northeast-1"
  }
}