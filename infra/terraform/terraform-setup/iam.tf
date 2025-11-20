resource "aws_iam_user" "terraform_executor" {
  name = var.terraform_iam_user_name

  tags = {
    Name        = "Terraform IAM User"
    Description = "Terraform実行専用IAMユーザー"
  }
}

resource "aws_iam_user_policy_attachment" "power_user" {
  user       = aws_iam_user.terraform_executor.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}
