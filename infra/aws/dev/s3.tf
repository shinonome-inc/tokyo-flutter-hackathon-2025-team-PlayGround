terraform {
  backend "s3" {
    bucket         = "genkaimeshi-recipe"
    key            = "aws/dev/terraform.tfstate"
    region         = "ap-northeast-1"
    encrypt        = true
  }
}
