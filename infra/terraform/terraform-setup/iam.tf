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

resource "aws_iam_user_policy" "terraform_backend_access" {
  name = "TerraformBackendAccess"
  user = aws_iam_user.terraform_executor.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::genkaimeshi-recipe-terraform-state",
          "arn:aws:s3:::genkaimeshi-recipe-terraform-state/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ]
        Resource = "arn:aws:dynamodb:ap-northeast-1:851725222522:table/terraform-lock"
      }
    ]
  })
}
