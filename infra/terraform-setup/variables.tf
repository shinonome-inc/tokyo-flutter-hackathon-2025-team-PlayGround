variable "project_name" {
  description = "プロジェクト名"
  type        = string
  default     = "genkaimeshi-recipe"
}

variable "aws_region" {
  description = "AWSリージョン"
  type        = string
  default     = "ap-northeast-1"
}

variable "state_bucket_name" {
  description = "Terraform stateファイルを保存するS3バケット名"
  type        = string
  default     = "genkaimeshi-recipe-terraform-state"
}

variable "dynamodb_table_name" {
  description = "Terraform state lockに使用するDynamoDBテーブル名"
  type        = string
  default     = "terraform-lock"
}

variable "terraform_iam_user_name" {
  description = "Terraform実行専用IAMユーザー名"
  type        = string
  default     = "terraform-iam-user"
}
