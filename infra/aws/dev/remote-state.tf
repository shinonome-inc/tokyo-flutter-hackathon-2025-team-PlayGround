terraform {
  backend "s3" {
    bucket         = "genkaimeshi-recipe-terraform-state"
    key            = "aws/dev/terraform.tfstate"
    region         = "ap-northeast-1"
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}
