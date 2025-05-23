variable "project_id" {
  description = "ID do projeto no Google Cloud"
  type        = string
}

variable "region" {
  description = "Região dos recursos"
  type        = string
  default     = "us-central1"
}

variable "bucket_name" {
  description = "Nome do bucket GCS fixo"
  type        = string
  default     = "function-bucket-quiosquefood"
}

variable "zip_object" {
  description = "Nome do arquivo ZIP no bucket"
  type        = string
  default     = "function-source.zip"
}
