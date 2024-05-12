job "dnscopy" {
  type = "batch"

  periodic {
    crons = ["@hourly"]
  }

  datacenters = ["CONTROL"]
  region = "debon"
  namespace = "default"

  group "dnscopy" {
    count = 1

    task "app" {
      driver = "docker"

      identity {
        env = true
      }

      config {
        image = "ghcr.io/the-maldridge/mkt-nomad-dns:v0.0.1"
        init = true
      }

      env {
        DNS_DOMAIN = "dal.michaelwashere.net"
        NOMAD_ADDR = "unix:///secrets/api.sock"
        NOMAD_TAG = "nomad-ddns"
      }

      template {
        data = <<EOF
{{ with nomadVar "nomad/jobs/dnscopy" }}
ROS_ADDRESS={{ .ROS_ADDRESS }}
ROS_USERNAME={{ .ROS_USERNAME }}
ROS_PASSWORD={{ .ROS_PASSWORD }}
{{ end }}
EOF
        destination = "${NOMAD_SECRETS_DIR}/env"
        env = true
      }
    }
  }
}
