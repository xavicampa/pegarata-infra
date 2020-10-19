variable "project_id" {
  description = "Google Project ID."
  type        = string
}

variable "region" {
  description = "Google Cloud region"
  type        = string
  default     = "europe-north1"
}

variable "machine_type" {
  description = "Google VM Instance type."
  type        = string
  default     = "e2-medium"
}

variable "cred_file" {
  description = "Credentials file"
  type        = string
}
