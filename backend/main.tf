terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
    random = {
      source  = "hashicorp/random"
    }
  }
}

provider "google" {
  version = "~> 3.42.0"
  credentials = file(var.cred_file)
  project = var.project_id
  region = var.region
}

# Create a GCS Bucket
resource "google_storage_bucket" "tf_bucket" {
  project       = var.project_id
  name          = var.gcp_bucket
  location      = var.region
  force_destroy = true
  storage_class = var.gcp_bucket_storage_class
  versioning {
    enabled = true
  }
}


