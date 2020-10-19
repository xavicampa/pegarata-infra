terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}

provider "google" {
  version     = "~> 3.42.0"
  credentials = file(var.cred_file)
  project     = var.project_id
  region      = var.region
}

provider "random" {
  version = "~> 3.0.0"
}

resource "google_compute_network" "vpc_network" {
  name = "vpc-network"
}

resource "google_service_account" "gke_sa" {
  account_id   = "gke-sa"
  display_name = "GKE service account"
  project      = var.project_id
}

resource "google_project_iam_binding" "gke_sa_logwriter_binding" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  members = ["serviceAccount:${google_service_account.gke_sa.email}"]
}

resource "google_project_iam_binding" "gke_sa_metricwriter_binding" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  members = ["serviceAccount:${google_service_account.gke_sa.email}"]
}

resource "google_project_iam_binding" "gke_sa_viewer_binding" {
  project = var.project_id
  role    = "roles/monitoring.viewer"
  members = ["serviceAccount:${google_service_account.gke_sa.email}"]
}

resource "google_project_iam_binding" "gke_sa_objectviewer_binding" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  members = ["serviceAccount:${google_service_account.gke_sa.email}"]
}

resource "google_service_account" "workloadidentity-sa" {
  account_id   = "workloadidentity-sa"
  display_name = "Workload Identity service account"
  project      = var.project_id
}

resource "google_container_cluster" "primary" {
  name     = "terraform-gke-cluster"
  location = var.region

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  workload_identity_config {
    identity_namespace = "${var.project_id}.svc.id.goog"
  }

  network = google_compute_network.vpc_network.self_link

  # VPC-native Cluster
  ip_allocation_policy {
    cluster_ipv4_cidr_block  = "/16"
    services_ipv4_cidr_block = "/22"
  }

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "terraform-node-pool"
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = var.machine_type

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only"
    ]

    service_account = google_service_account.gke_sa.email
  }
}
