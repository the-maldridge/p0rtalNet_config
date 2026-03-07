job "esphome" {
  type = "service"
  datacenters = ["CONTROL"]
  region = "debon"
  namespace = "default"

  group "esphome" {
    count = 1

    network {
      mode = "cni/svcs"
      port "http" { to = 6052 }
    }

    service {
      provider = "nomad"
      name = "esphome"
      port = "http"
      address_mode = "alloc"
      tags = ["traefik.enable=true"]
    }

    volume "esphome" {
      type = "host"
      source = "esphome_data"
      read_only = false
    }

    task "esphome" {
      driver = "docker"

      config {
        image = "docker.io/esphome/esphome:2025.6.2"
      }

      resources {
        memory = 1000
      }

      volume_mount {
        volume = "esphome"
        destination = "/config"
      }
    }
  }
}
