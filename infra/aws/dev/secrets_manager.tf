resource "aws_secretsmanager_secret" "gemini_api_key" {
  name        = "${var.project_name}-gemini-api-key"
  description = "Gemini API用のシークレットキーを安全に保管するためのSecretsManagerリソース"

  kms_key_id = aws_kms_key.secrets_encryption.key_id
}

resource "aws_secretsmanager_secret_version" "gemini_api_key" {
  secret_id     = aws_secretsmanager_secret.gemini_api_key.id
  secret_string = jsonencode({
    gemini_api_key = var.gemini_api_key
  })
}

resource "aws_secretsmanager_secret" "gcp_service_account_key" {
  name        = "${var.project_name}-gcp-service-account-key"
  description = "GCP Vertex AI用のサービスアカウントキーを安全に保管するためのSecretsManagerリソース"

  kms_key_id = aws_kms_key.secrets_encryption.key_id
}

resource "aws_secretsmanager_secret_version" "gcp_service_account_key" {
  secret_id     = aws_secretsmanager_secret.gcp_service_account_key.id
  secret_string = var.gcp_service_account_key
}

resource "aws_kms_key" "secrets_encryption" {
  description             = "Secrets Manager用の暗号化キー"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}
