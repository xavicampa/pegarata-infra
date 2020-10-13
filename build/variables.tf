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
