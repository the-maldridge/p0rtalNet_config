resource "junos_application" "ssh" {
  name             = "ssh"
  protocol         = "tcp"
  destination_port = "22"
}
