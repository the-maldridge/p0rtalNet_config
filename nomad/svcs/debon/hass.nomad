job "homeassistant" {
  type = "service"
  datacenters = ["CONTROL"]
  region = "debon"
  namespace = "default"

  group "homeassistant" {
    count = 1

    network {
      mode = "cni/svcs"
      port "http" { static = 8123}
    }

    service {
      provider = "nomad"
      name = "hass"
      port = "http"
      address_mode = "alloc"
      tags = ["nomad-ddns"]
    }

    volume "hass" {
      type = "host"
      source = "homeassistant_data"
      read_only = false
    }

    task "homeassistant" {
      driver = "docker"

      config {
        image = "ghcr.io/home-assistant/home-assistant:2024.5.1"
        devices = [{
          host_path = "/dev/serial/by-id/usb-Nabu_Casa_SkyConnect_v1.0_44fa4919b4d8ed11a5036b6162c613ac-if00-port0"
          container_path = "/dev/ttyUSB0"
        }]
      }

      resources {
        memory = 2000
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
