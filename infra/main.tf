terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.65.2"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# ✅ Bucket fixo para os arquivos ZIP das funções
resource "google_storage_bucket" "function_bucket" {
  name          = var.bucket_name
  location      = var.region
  force_destroy = true

  uniform_bucket_level_access = true
}

# ✅ Dataset BigQuery
resource "google_bigquery_dataset" "dataset" {
  dataset_id = "QuiosqueFood"
  location   = "US"
}

# ✅ Tabela BigQuery
resource "google_bigquery_table" "customers" {
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "customers"

  schema = jsonencode([
    { name = "id", type = "STRING", mode = "REQUIRED" },
    { name = "nome", type = "STRING", mode = "REQUIRED" },
    { name = "email", type = "STRING", mode = "REQUIRED" },
    { name = "cpf", type = "STRING", mode = "REQUIRED" }
  ])
}

# ✅ Arquivo ZIP da função (é gerado e enviado pelo GitHub Actions)
resource "google_storage_bucket_object" "function_archive" {
  name   = var.zip_object
  bucket = google_storage_bucket.function_bucket.name
  source = var.zip_object
}

# ✅ Função - Create Customer
resource "google_cloudfunctions_function" "create_customer" {
  name                  = "create-customer"
  runtime               = "nodejs20"
  available_memory_mb   = 256
  trigger_http          = true
  entry_point           = "criarCustomer"

  source_archive_bucket = google_storage_bucket.function_bucket.name
  source_archive_object = google_storage_bucket_object.function_archive.name

  environment_variables = {
    DATASET = google_bigquery_dataset.dataset.dataset_id
    TABLE   = google_bigquery_table.customers.table_id
  }
}

# ✅ Função - Get Customer
resource "google_cloudfunctions_function" "get_customer" {
  name                  = "get-customer"
  runtime               = "nodejs20"
  available_memory_mb   = 256
  trigger_http          = true
  entry_point           = "pesquisarCustomerPorCpf"

  source_archive_bucket = google_storage_bucket.function_bucket.name
  source_archive_object = google_storage_bucket_object.function_archive.name

  environment_variables = {
    DATASET = google_bigquery_dataset.dataset.dataset_id
    TABLE   = google_bigquery_table.customers.table_id
  }
}

# ✅ Função - Update Customer
resource "google_cloudfunctions_function" "update_customer" {
  name                  = "update-customer"
  runtime               = "nodejs20"
  available_memory_mb   = 256
  trigger_http          = true
  entry_point           = "editarCustomerPorCpf"

  source_archive_bucket = google_storage_bucket.function_bucket.name
  source_archive_object = google_storage_bucket_object.function_archive.name

  environment_variables = {
    DATASET = google_bigquery_dataset.dataset.dataset_id
    TABLE   = google_bigquery_table.customers.table_id
  }
}

# ✅ Função - Delete Customer
resource "google_cloudfunctions_function" "delete_customer" {
  name                  = "delete-customer"
  runtime               = "nodejs20"
  available_memory_mb   = 256
  trigger_http          = true
  entry_point           = "excluirCustomerPorCpf"

  source_archive_bucket = google_storage_bucket.function_bucket.name
  source_archive_object = google_storage_bucket_object.function_archive.name

  environment_variables = {
    DATASET = google_bigquery_dataset.dataset.dataset_id
    TABLE   = google_bigquery_table.customers.table_id
  }
}
