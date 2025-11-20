provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      ManagedBy   = "Terraform"
      Environment = "prod"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}
