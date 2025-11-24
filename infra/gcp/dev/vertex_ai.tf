resource "google_project_service" "vertex_ai" {
  project = var.gcp_project_id
  service = "aiplatform.googleapis.com"

  disable_dependent_services = false
  disable_on_destroy         = false
}

resource "google_project_service" "generative_language_api" {
  project = var.gcp_project_id
  service = "generativelanguage.googleapis.com"

  disable_dependent_services = false
  disable_on_destroy         = false
}
