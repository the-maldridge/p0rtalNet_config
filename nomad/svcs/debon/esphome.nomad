job "esphome" {
  type = "service"
  datacenters = ["CONTROL"]
  region = "debon"
  namespace = "default"

  group "esphome" {
    count = 1

    network {
      mode = "cni/svcs"
      port "http" { static = 6052 }
    }

    service {
      provider = "nomad"
      name = "esphome"
      port = "http"
      address_mode = "alloc"
      tags = ["nomad-ddns"]
    }

    volume "esphome" {
      type = "host"
      source = "esphome_data"
      read_only = false
    }

    task "esphome" {
      driver = "docker"

      config {
        image = "docker.io/esphome/esphome:2024.2.0"
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
