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

variable "google_client_id" {
  description = "Google OAuth クライアントID"
  type        = string
  sensitive   = true
}

variable "google_client_secret" {
  description = "Google OAuth クライアントシークレット"
  type        = string
  sensitive   = true
}

variable "line_channel_id" {
  description = "LINE Login チャンネルID"
  type        = string
  sensitive   = true
}

variable "line_channel_secret" {
  description = "LINE Login チャンネルシークレット"
  type        = string
  sensitive   = true
}

variable "cognito_callback_urls" {
  description = "Cognito認証後のコールバックURL"
  type        = list(string)
  default     = ["myapp://callback"]
}

variable "cognito_logout_urls" {
  description = "Cognitoログアウト後のリダイレクトURL"
  type        = list(string)
  default     = ["myapp://logout"]
}

variable "gemini_api_key" {
  description = "Gemini APIキー"
  type        = string
  sensitive   = true
}

variable "gcp_project_id" {
  description = "GCPプロジェクトID"
  type        = string
  default     = "genkaimeshi-recipe"
}

variable "gcp_service_account_key" {
  description = "GCP Vertex AI用のサービスアカウントキー（JSON文字列）"
  type        = string
  sensitive   = true
}
