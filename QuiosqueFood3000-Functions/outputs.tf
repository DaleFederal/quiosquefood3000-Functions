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
