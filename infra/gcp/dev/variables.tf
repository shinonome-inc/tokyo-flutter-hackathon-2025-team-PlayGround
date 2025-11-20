variable "project_name" {
  description = "プロジェクト名"
  type        = string
  default     = "genkaimeshi-recipe"
}

variable "gcp_project_id" {
  description = "Google CloudプロジェクトID"
  type        = string
  default     = "genkaimeshi-recipe"
}

variable "gcp_region" {
  description = "Google Cloudリージョン"
  type        = string
  default     = "asia-northeast1"
}
