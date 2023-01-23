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

resource "junos_application" "wg_peers" {
  for_each = toset(["51821", "51822", "51823", "51824", "52820"])

  name             = "wireguard_bgp_${each.value}"
  protocol         = "udp"
  destination_port = each.value
}
