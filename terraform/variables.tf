variable "project_id" {
  description = "The GCP project ID"
  type        = string
  default     = "quiosquefood3000"
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "us-central1"
}

variable "bucket_name" {
  description = "The name of the storage bucket for Cloud Functions source code"
  type        = string
  default     = "function-bucket-quiosquefood"
}

variable "zip_object" {
  description = "The name of the ZIP file containing the function source code"
  type        = string
  default     = "function-source.zip"
}