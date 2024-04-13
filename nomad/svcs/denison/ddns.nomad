job "ddns" {
  type = "service"
  namespace = "default"
  datacenters = ["CONTROL"]
  region = "kdns"

  group "ddns" {
    count = 1

    network {
      mode = "bridge"
      port "http" { static = 8000 }
    }

    task "app" {
      driver = "docker"

      config {
        image = "ghcr.io/qdm12/ddns-updater:v2.6.0"
        cap_add = ["NET_BIND_SERVICE"]
      }

      env {
        DATADIR = "/secrets"
      }

      resources {
        memory = 64
      }

      template {
        data = jsonencode({
          settings = [
            {
              provider = "namecheap"
              domain = "michaelwashere.net"
              host = "gyi"
              password = "{{ with nomadVar `nomad/jobs/ddns` }}{{.password}}{{ end }}"
              provider_ip = true
            }
          ]
        })
        destination = "secrets/config.json"
      }
    }
  }
}
