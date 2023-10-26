job "speedtest" {
  type = "service"

  datacenters = ["CONTROL"]
  region = "debon"
  namespace = "default"

  group "speedtest" {
    count = 1

    network {
      mode = "cni/dmz"
      hostname = "speedtest"

      port "http" { static = 80 }
    }

    service {
      provider = "nomad"
      name = "speedtest"
      port = "http"
      address_mode = "alloc"
    }

    volume "speedtest_data" {
      type = "host"
      source = "speedtest_data"
      read_only = false
    }

    task "app" {
      driver = "docker"

      config {
        image = "docker.io/e7db/speedtest"
      }

      volume_mount {
        volume = "speedtest_data"
        destination = "/app/results"
      }
    }
  }
}
