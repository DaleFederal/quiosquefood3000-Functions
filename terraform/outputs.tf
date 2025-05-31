output "gateway_url" {
  value = "https://${google_api_gateway_gateway.customer_gateway.default_hostname}"
}

output "create_customer_url" {
  value = google_cloudfunctions_function.create_customer.https_trigger_url
}

output "pesquisar_customer_url" {
  value = google_cloudfunctions_function.pesquisar_customer.https_trigger_url
}

output "update_customer_url" {
  value = google_cloudfunctions_function.update_customer.https_trigger_url
}

output "delete_customer_url" {
  value = google_cloudfunctions_function.delete_customer.https_trigger_url
}