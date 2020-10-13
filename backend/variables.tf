variable "project_id" {
    description = "Google Project ID."
    type        = string
}

variable "region" {
    description = "Google Cloud region"
    type        = string
    default     = "europe-north1"
}

variable "cred_file" {
    description = "Credentials file"
    type = string
}

variable "gcp_bucket" {
    type = string
}

variable "gcp_bucket_storage_class" {
  type        = string
  description = "The storage class of the Storage Bucket to create"
}