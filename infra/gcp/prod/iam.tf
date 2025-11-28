resource "google_service_account" "vision_service_account" {
  account_id   = "vision-service-account"
  display_name = "Cloud Vision Service Account"
  project      = var.gcp_project_id
}

resource "google_service_account_key" "vision_service_account_key" {
  service_account_id = google_service_account.vision_service_account.id
}

output "vision_service_account_email" {
  value       = google_service_account.vision_service_account.email
  description = "Cloud Vision Service Account Email"
}
