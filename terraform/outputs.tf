output "create_customer_url" {
  value = google_cloudfunctions_function.create_customer.https_trigger_url
}

output "get_customer_url" {
  value = google_cloudfunctions_function.get_customer.https_trigger_url
}

output "update_customer_url" {
  value = google_cloudfunctions_function.update_customer.https_trigger_url
}

output "delete_customer_url" {
  value = google_cloudfunctions_function.delete_customer.https_trigger_url
}

output "api_gateway_url" {
  value       = google_api_gateway_gateway.customers_gateway.default_hostname
  description = "URL do API Gateway para acessar todas as APIs de customers"
}

output "api_gateway_full_url" {
  value       = "https://${google_api_gateway_gateway.customers_gateway.default_hostname}"
  description = "URL completa do API Gateway"
}