terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.66.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 4.66.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

resource "google_storage_bucket" "function_bucket" {
  name          = var.bucket_name
  location      = var.region
  force_destroy = true

  uniform_bucket_level_access = true
}

resource "google_bigquery_dataset" "dataset" {
  dataset_id = "QuiosqueFood"
  location   = "US"
}

resource "google_bigquery_table" "customers" {
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "customers"

  deletion_protection = false

  schema = jsonencode([
    { name = "id", type = "STRING", mode = "REQUIRED" },
    { name = "name", type = "STRING", mode = "REQUIRED" },
    { name = "email", type = "STRING", mode = "REQUIRED" },
    { name = "cpf", type = "STRING", mode = "REQUIRED" }
  ])
}

resource "google_pubsub_topic" "customer_topic" {
  name    = "customer"
  project = var.project_id
}

resource "google_storage_bucket_object" "function_archive" {
  name   = var.zip_object
  bucket = google_storage_bucket.function_bucket.name
  source = "../${var.zip_object}"
}

# Cloud Functions
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
    TOPIC   = google_pubsub_topic.customer_topic.name
  }

  depends_on = [google_storage_bucket.function_bucket]
}

resource "google_cloudfunctions_function" "pesquisar_customer" {
  name                  = "pesquisar-customer"
  runtime               = "nodejs20"
  available_memory_mb   = 256
  trigger_http          = true
  entry_point           = "pesquisarCustomerPorCpf"

  source_archive_bucket = google_storage_bucket.function_bucket.name
  source_archive_object = google_storage_bucket_object.function_archive.name

  environment_variables = {
    DATASET = google_bigquery_dataset.dataset.dataset_id
    TABLE   = google_bigquery_table.customers.table_id
    TOPIC   = google_pubsub_topic.customer_topic.name
  }

  depends_on = [google_storage_bucket.function_bucket]
}

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
    TOPIC   = google_pubsub_topic.customer_topic.name
  }

  depends_on = [google_storage_bucket.function_bucket]
}

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
    TOPIC   = google_pubsub_topic.customer_topic.name
  }

  depends_on = [google_storage_bucket.function_bucket]
}

resource "google_cloudfunctions_function" "customer_pubsub_messenger" {
  name                  = "customer-pubsub-messenger"
  runtime               = "nodejs20"
  available_memory_mb   = 256
  entry_point           = "customerPubSubMessenger"

  source_archive_bucket = google_storage_bucket.function_bucket.name
  source_archive_object = google_storage_bucket_object.function_archive.name

  event_trigger {
    event_type = "google.pubsub.topic.publish"
    resource   = google_pubsub_topic.customer_topic.id
  }

  environment_variables = {
    DATASET = google_bigquery_dataset.dataset.dataset_id
    TABLE   = google_bigquery_table.customers.table_id
    TOPIC   = google_pubsub_topic.customer_topic.name
  }

  depends_on = [google_storage_bucket.function_bucket]
}

# Service Account para o API Gateway
resource "google_service_account" "api_gateway_sa" {
  account_id   = "api-gateway-sa"
  display_name = "API Gateway Service Account"
  description  = "Service Account para o API Gateway invocar Cloud Functions"
}

# API Gateway
resource "google_api_gateway_api" "customer_api" {
  provider = google-beta
  api_id   = "customer-api"
}

resource "google_api_gateway_api_config" "customer_api_config" {
  provider      = google-beta
  api           = google_api_gateway_api.customer_api.api_id
  api_config_id = "v1"

  openapi_documents {
    document {
      path     = "openapi.yaml"
      contents = base64encode(file("openapi.yaml"))
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_api_gateway_gateway" "customer_gateway" {
  provider = google-beta
  
  gateway_id = "customer-gateway"
  api_config = google_api_gateway_api_config.customer_api_config.id
  region     = "us-central1"
}

# IAM para API Gateway acessar as Cloud Functions
resource "google_cloudfunctions_function_iam_member" "create_customer_invoker" {
  project        = google_cloudfunctions_function.create_customer.project
  region         = google_cloudfunctions_function.create_customer.region
  cloud_function = google_cloudfunctions_function.create_customer.name

  role   = "roles/cloudfunctions.invoker"
  member = "serviceAccount:${google_service_account.api_gateway_sa.email}"
}

resource "google_cloudfunctions_function_iam_member" "pesquisar_customer_invoker" {
  project        = google_cloudfunctions_function.pesquisar_customer.project
  region         = google_cloudfunctions_function.pesquisar_customer.region
  cloud_function = google_cloudfunctions_function.pesquisar_customer.name

  role   = "roles/cloudfunctions.invoker"
  member = "serviceAccount:${google_service_account.api_gateway_sa.email}"
}

resource "google_cloudfunctions_function_iam_member" "update_customer_invoker" {
  project        = google_cloudfunctions_function.update_customer.project
  region         = google_cloudfunctions_function.update_customer.region
  cloud_function = google_cloudfunctions_function.update_customer.name

  role   = "roles/cloudfunctions.invoker"
  member = "serviceAccount:${google_service_account.api_gateway_sa.email}"
}

resource "google_cloudfunctions_function_iam_member" "delete_customer_invoker" {
  project        = google_cloudfunctions_function.delete_customer.project
  region         = google_cloudfunctions_function.delete_customer.region
  cloud_function = google_cloudfunctions_function.delete_customer.name

  role   = "roles/cloudfunctions.invoker"
  member = "serviceAccount:${google_service_account.api_gateway_sa.email}"
}