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
      driver = "podman"

      config {
        image = "ghcr.io/qdm12/ddns-updater:latest"
      }

      env {
        DATADIR = "/secrets"
      }

      resources {
        memory = 64
      }

      template {
        data = <<EOF
{
    "settings": [
        {
            "provider": "google",
            "domain": "michaelwashere.net",
            "host": "kdns",
{{ with nomadVar "nomad/jobs/ddns" -}}
            "username": "{{.username}}",
            "password": "{{.password}}",
{{ end -}}
            "ip_version": "ipv4"
        }
    ]
}
EOF
        destination = "secrets/config.json"
      }
    }
  }
}
