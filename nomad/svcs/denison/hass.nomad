job "homeassistant" {
  type = "service"
  datacenters = ["CONTROL"]
  region = "kdns"
  namespace = "default"

  group "homeassistant" {
    count = 1

    network {
      mode = "host"
      port "http" { static = 8123 }
    }

    volume "hass" {
      type = "host"
      source = "hass"
      read_only = false
    }

    task "homeassistant" {
      driver = "docker"

      config {
        image = "ghcr.io/home-assistant/home-assistant:2022.11.4"
        network_mode = "host"
      }

      env {
        TZ = "America/Chicago"
      }

      volume_mount {
        volume = "hass"
        destination = "/config"
      }
    }
  }
}
