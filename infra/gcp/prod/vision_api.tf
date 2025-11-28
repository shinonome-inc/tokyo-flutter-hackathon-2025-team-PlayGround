resource "google_project_service" "vision_api" {
  project            = var.gcp_project_id
  service            = "vision.googleapis.com"
  disable_on_destroy = false
}
