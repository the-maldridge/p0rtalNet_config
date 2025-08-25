job "proxy" {
  name        = "proxy"
  datacenters = ["CONTROL", "WORKER"]
  type        = "system"

  group "traefik" {
    network {
      mode = "cni/svcs"
      port "http" { static = 80 }
      port "https" { static = 443 }
      port "metrics" { static = 8080 }
    }

    service {
      name = "proxy"
      port     = "http"
      provider = "nomad"
      address_mode = "alloc"
      tags = [
        "traefik.http.routers.dashboard.rule=Host(`proxy.dal.michaelwashere.net`)",
        "traefik.http.routers.dashboard.service=api@internal",
        "nomad-ddns",
      ]
    }

    task "traefik" {
      driver = "docker"

      identity {
        env         = true
        change_mode = "restart"
      }

      config {
        image = "traefik:v3.3.4"

        args = [
          "--accesslog=false",
          "--api.dashboard",
          "--entrypoints.http.address=:80",
          "--metrics.prometheus",
          "--ping=true",
          "--providers.nomad.refreshInterval=30s",
          "--providers.nomad.endpoint.address=unix://${NOMAD_SECRETS_DIR}/api.sock",
          "--providers.nomad.defaultRule=Host(`{{ .Name }}.dal.michaelwashere.net`)",
          "--providers.file.filename=/local/config.yaml",
        ]
      }

      template {
        data = yamlencode({
          http = {
            services = {
              nomad = {
                loadBalancer = {
                  servers = [
                    { url = "http://172.26.64.1:4646" },
                  ]
                }
              }
            }
            routers = {
              nomad = {
                rule    = "Host(`nomad.dal.michaelwashere.net`)"
                service = "nomad"
              }
            }
          }
        })
        destination = "local/config.yaml"
      }
    }
  }
}
