terraform {
    backend "gcs" {
        bucket = "xavic-tfstate-bucket"
        prefix = "gke-cluster"
        credentials = "../creds.json"
    }
}