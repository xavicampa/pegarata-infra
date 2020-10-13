terraform {
  required_providers {
    google = {
      source = "hashicorp/google-beta"
    }
  }
}

provider "google-beta" {
  credentials = file(var.cred_file)
  project = var.project_id
  region = var.region
}

provider "random" {
  version = "~> 3.0.0"
}

resource "google_cloudbuild_trigger" "default" {
  description    = "Push to any branch"
  github {
    owner = "xavicampa"
    name = "xavic-test"
    push {
      branch = ".*"
    }
  }
  build  {
    images = ["gcr.io/my-project-1526573572937/github.com/xavicampa/xavic-test:$COMMIT_SHA"]
    step {
      name = "gcr.io/cloud-builders/docker"
      args = ["build", "-t", "gcr.io/my-project-1526573572937/github.com/xavicampa/xavic-test:$COMMIT_SHA", "."]
    }
  }
}