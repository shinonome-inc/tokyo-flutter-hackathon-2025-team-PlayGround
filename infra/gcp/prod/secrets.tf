# GCPのサービスアカウントキーをAWS Secrets Managerに保存するための出力
# 実際のSecrets Managerリソースはinfra/aws/prod/secrets_manager.tfに定義

output "vision_service_account_key_private_key" {
  value       = google_service_account_key.vision_service_account_key.private_key
  description = "Cloud Vision Service Account Private Key (base64 encoded)"
  sensitive   = true
}
