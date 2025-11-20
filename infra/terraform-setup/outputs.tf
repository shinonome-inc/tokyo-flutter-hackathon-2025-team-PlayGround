output "state_bucket_name" {
  description = "作成されたTerraform state用S3バケット名"
  value       = aws_s3_bucket.terraform_state.id
}

output "state_bucket_arn" {
  description = "作成されたTerraform state用S3バケットのARN"
  value       = aws_s3_bucket.terraform_state.arn
}

output "dynamodb_table_name" {
  description = "作成されたTerraform lock用DynamoDBテーブル名"
  value       = aws_dynamodb_table.terraform_lock.name
}

output "dynamodb_table_arn" {
  description = "作成されたTerraform lock用DynamoDBテーブルのARN"
  value       = aws_dynamodb_table.terraform_lock.arn
}

output "terraform_iam_user_name" {
  description = "作成されたTerraform実行用IAMユーザー名"
  value       = aws_iam_user.terraform_executor.name
}

output "terraform_iam_user_arn" {
  description = "作成されたTerraform実行用IAMユーザーのARN"
  value       = aws_iam_user.terraform_executor.arn
}

output "next_steps" {
  description = "次のステップ"
  value = <<-EOT

  ✅ Bootstrap完了！次のステップ:

  1. Terraform実行用IAMユーザーのアクセスキーを作成:
     aws iam create-access-key --user-name ${aws_iam_user.terraform_executor.name}

  2. 出力されたアクセスキーを新しいプロファイルとして設定:
     aws configure --profile terraform

  3. 以降のTerraform実行時は以下を指定:
     export AWS_PROFILE=terraform
  EOT
}
