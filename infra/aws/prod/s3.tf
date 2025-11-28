terraform {
  backend "s3" {
    bucket         = "genkaimeshi-recipe"
    key            = "aws/prod/terraform.tfstate"
    region         = "ap-northeast-1"
    encrypt        = true
  }
}
