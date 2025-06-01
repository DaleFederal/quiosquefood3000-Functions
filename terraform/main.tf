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

  schema = jsonencode([
    { name = "id", type = "INT64", mode = "REQUIRED" },
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

resource "google_cloudfunctions_function_iam_member" "invoker_authenticated" {
  project        = google_cloudfunctions_function.create_customer.project
  region         = google_cloudfunctions_function.create_customer.region
  cloud_function = google_cloudfunctions_function.create_customer.name

  role   = "roles/cloudfunctions.invoker"
  member = "allAuthenticatedUsers"
}

resource "google_api_gateway_api" "customers_api" {
  api_id = "customers-api"
  display_name = "Customers API"
}

resource "google_api_gateway_api_config" "customers_api_config" {
  api      = google_api_gateway_api.customers_api.api_id
  api_config_id = "customers-api-config"
  display_name  = "Customers API Config"

  openapi_documents {
    document {
      path     = "../openapi.yaml"
      contents = file("../openapi.yaml")
    }
  }

  depends_on = [
    google_cloudfunctions_function.create_customer,
    google_cloudfunctions_function.get_customer,
    google_cloudfunctions_function.update_customer,
    google_cloudfunctions_function.delete_customer
  ]
}

resource "google_api_gateway_gateway" "customers_gateway" {
  gateway_id = "customers-gateway"
  api_config = google_api_gateway_api_config.customers_api_config.id
  location   = var.region
}

resource "null_resource" "wait_for_gateway" {
  provisioner "local-exec" {
    command = "sleep 60"
  }

  depends_on = [google_api_gateway_gateway.customers_gateway]
}

resource "google_cloudfunctions_function_iam_member" "gateway_invoker_create" {
  project        = var.project_id
  region         = var.region
  cloud_function = google_cloudfunctions_function.create_customer.name
  role           = "roles/cloudfunctions.invoker"
  member         = "serviceAccount:${google_api_gateway_gateway.customers_gateway.gateway_id}.uc.gateway.dev@${var.project_id}.iam.gserviceaccount.com"

  depends_on = [null_resource.wait_for_gateway]
}

resource "google_cloudfunctions_function_iam_member" "gateway_invoker_get" {
  project        = var.project_id
  region         = var.region
  cloud_function = google_cloudfunctions_function.get_customer.name
  role           = "roles/cloudfunctions.invoker"
  member         = "serviceAccount:${google_api_gateway_gateway.customers_gateway.gateway_id}.uc.gateway.dev@${var.project_id}.iam.gserviceaccount.com"

  depends_on = [null_resource.wait_for_gateway]
}

resource "google_cloudfunctions_function_iam_member" "gateway_invoker_update" {
  project        = var.project_id
  region         = var.region
  cloud_function = google_cloudfunctions_function.update_customer.name
  role           = "roles/cloudfunctions.invoker"
  member         = "serviceAccount:${google_api_gateway_gateway.customers_gateway.gateway_id}.uc.gateway.dev@${var.project_id}.iam.gserviceaccount.com"

  depends_on = [null_resource.wait_for_gateway]
}

resource "google_cloudfunctions_function_iam_member" "gateway_invoker_delete" {
  project        = var.project_id
  region         = var.region
  cloud_function = google_cloudfunctions_function.delete_customer.name
  role           = "roles/cloudfunctions.invoker"
  member         = "serviceAccount:${google_api_gateway_gateway.customers_gateway.gateway_id}.uc.gateway.dev@${var.project_id}.iam.gserviceaccount.com"

  depends_on = [null_resource.wait_for_gateway]
}