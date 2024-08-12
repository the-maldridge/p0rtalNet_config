output "capsman_certificate" {
  value       = routeros_wifi_capsman.mgr.generated_certificate
  description = "Certificate for communicating with CAPsMAN"
}
