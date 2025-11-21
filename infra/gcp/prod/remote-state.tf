terraform {
  backend "gcs" {
    bucket = "genkaimeshi-recipe-terraform-state"
    prefix = "gcp/prod"
  }
}
