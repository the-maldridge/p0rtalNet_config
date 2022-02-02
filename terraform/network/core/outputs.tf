resource "local_file" "network_info" {
  content = jsonencode({
    networks = var.networks
  })
  filename = "${path.module}/ansible_vars.yml"
  file_permission = "0644"
}
