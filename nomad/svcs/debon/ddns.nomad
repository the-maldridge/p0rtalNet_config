job "ddns" {
  type = "service"

  datacenters = ["CONTROL"]
  region = "debon"
  namespace = "default"

  group "ddns" {
    count = 1

    network {
      mode = "cni/svcs"
      hostname = "ddns"

      port "http" { to = 80 }
    }

    service {
      provider = "nomad"
      name = "ddns"
      port = "http"
      address_mode = "alloc"
      tags = ["nomad-ddns"]
    }

    volume "ddns_data" {
      type = "host"
      source = "ddns_data"
      read_only = false
    }

    task "app" {
      driver = "docker"

      config {
        image = "ghcr.io/qdm12/ddns-updater:v2.6.0"
        cap_add = ["NET_BIND_SERVICE"]
        volumes = ["secrets/config.json:/updater/data/config.json"]
      }

      env {
        LISTENING_ADDRESS=":80"
      }

      template {
        data = jsonencode({
          settings = [
            {
              provider = "namecheap"
              domain = "michaelwashere.net"
              host = "dal"
              password = "{{ with nomadVar `nomad/jobs/ddns` }}{{.password}}{{ end }}"
              provider_ip = true
            }
          ]
        })
        destination = "secrets/config.json"
      }

      volume_mount {
        volume = "ddns_data"
        destination = "/updater/data"
      }
    }
  }
}
