resource "junos_application" "ssh" {
  name             = "ssh"
  protocol         = "tcp"
  destination_port = "22"
}

resource "junos_application" "http" {
  name             = "http"
  protocol         = "tcp"
  destination_port = 80
}

resource "junos_application" "minecraft" {
  name             = "minecraft"
  protocol         = "tcp"
  destination_port = 25565
}
