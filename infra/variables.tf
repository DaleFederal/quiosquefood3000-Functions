variable "project_id" {
  description = "ID do projeto no Google Cloud"
  type        = string
}

variable "region" {
  description = "Região para os recursos"
  type        = string
  default     = "us-central1"
}

variable "bucket_name" {
  description = "Nome do bucket onde o ZIP da função será armazenado"
  type        = string
}

variable "zip_object" {
  description = "Nome do arquivo ZIP dentro do bucket"
  type        = string
  default     = "function-source.zip"
}
