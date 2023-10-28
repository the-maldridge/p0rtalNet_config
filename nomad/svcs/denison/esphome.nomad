job "esphome" {
  type = "service"
  datacenters = ["CONTROL"]
  region = "kdns"
  namespace = "default"

  group "esphome" {
    count = 1

    network {
      mode = "host"
      port "http" { static = 6052 }
    }

    volume "esphome" {
      type = "host"
      source = "esphome"
      read_only = false
    }

    task "esphome" {
      driver = "podman"

      config {
        image = "docker.io/esphome/esphome:2022.12.8"
        network_mode = "host"
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
